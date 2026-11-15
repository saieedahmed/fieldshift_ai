import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { GoogleGenAI } from "@google/genai";
import { rateLimit } from "express-rate-limit";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, ".env") });

const app = express();
const PORT = Number(process.env.PORT) || 3000;

// Render proxy configuration
app.set("trust proxy", 1);

// Gemini configuration
const apiKey = process.env.GEMINI_API_KEY?.trim();
const ai = apiKey ? new GoogleGenAI({ apiKey }) : null;

const CONFIGURED_MODEL = process.env.GEMINI_MODEL?.trim() || "gemini-flash-lite-latest";
const FALLBACK_MODELS = [
  "gemini-flash-lite-latest",
  "gemini-3.5-flash-lite",
  "gemini-3.1-flash-lite",
];

// Cooldown tracker for models hitting quota (429) or demand spikes (503)
const modelCooldowns = new Map();

function isModelInCooldown(model) {
  const expiresAt = modelCooldowns.get(model);
  if (!expiresAt) return false;
  if (Date.now() > expiresAt) {
    modelCooldowns.delete(model);
    return false;
  }
  return true;
}

function setModelCooldown(model, durationMs, reason) {
  modelCooldowns.set(model, Date.now() + durationMs);
  console.warn(`[Model Cooldown] Model "${model}" in cooldown for ${Math.round(durationMs / 1000)}s: ${reason}`);
}

function getCandidateModels() {
  const ordered = [CONFIGURED_MODEL, ...FALLBACK_MODELS.filter((m) => m !== CONFIGURED_MODEL)];
  const available = ordered.filter((m) => !isModelInCooldown(m));
  return available.length > 0 ? available : ordered;
}

// CORS configuration
const allowedOrigins = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(",").map((origin) => origin.trim()).filter(Boolean)
  : [];

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
        return callback(null, true);
      }
      return callback(new Error("Origin not allowed."));
    },
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Accept", "Authorization"],
  })
);

// Request size limit
app.use(express.json({ limit: "150kb" }));

// General health check
app.get("/", (req, res) => {
  res.json({
    success: true,
    name: "FieldShift AI Backend",
    message: "FieldShift AI Backend is running 🌱",
    timestamp: new Date().toISOString(),
  });
});

// Cache for live status probe to prevent spamming Gemini API
let statusCache = {
  lastCheck: 0,
  data: null,
};

/**
 * Utility to run a promise with a hard timeout
 */
function withTimeout(promise, ms, timeoutMessage = "Operation timed out") {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error(timeoutMessage));
    }, ms);

    promise
      .then((val) => {
        clearTimeout(timer);
        resolve(val);
      })
      .catch((err) => {
        clearTimeout(timer);
        reject(err);
      });
  });
}

async function getLiveGeminiStatus(force = false) {
  if (!ai) {
    return {
      connected: false,
      aiEnabled: false,
      provider: null,
      message: "GEMINI_API_KEY is not configured.",
    };
  }

  const now = Date.now();
  if (!force && statusCache.data && now - statusCache.lastCheck < 30000) {
    return statusCache.data;
  }

  const candidates = getCandidateModels();
  const start = Date.now();
  let activeModel = null;
  let connectionSuccess = false;
  let lastError = null;

  for (const model of candidates) {
    try {
      const probe = await withTimeout(
        ai.models.generateContent({
          model,
          contents: "Respond with OK",
          config: { maxOutputTokens: 5 },
        }),
        20000,
        `Probe timed out on ${model}`
      );
      if (probe && probe.text) {
        connectionSuccess = true;
        activeModel = model;
        break;
      }
    } catch (err) {
      lastError = err.message;
      const is429 = err.message.includes("429") || err.message.includes("RESOURCE_EXHAUSTED");
      const is503 = err.message.includes("503") || err.message.includes("high demand") || err.message.includes("UNAVAILABLE");
      if (is429) {
        setModelCooldown(model, 30 * 60 * 1000, "Quota exhausted (429) during probe");
      } else if (is503) {
        setModelCooldown(model, 60 * 1000, "Demand spike (503) during probe");
      }
      console.warn(`Status probe on ${model} failed: ${err.message}. Checking next candidate...`);
    }
  }

  const latencyMs = Date.now() - start;
  const result = {
    connected: connectionSuccess,
    aiEnabled: true,
    provider: "Gemini",
    configuredModel: CONFIGURED_MODEL,
    activeModel: connectionSuccess ? activeModel : null,
    latencyMs,
    timestamp: new Date().toISOString(),
    ...(lastError && !connectionSuccess ? { error: lastError } : {}),
  };

  statusCache = { lastCheck: now, data: result };
  return result;
}

// Live AI status endpoint
app.get(["/api/status", "/status"], async (req, res) => {
  try {
    const status = await getLiveGeminiStatus(req.query.refresh === "true");
    const httpStatus = status.connected ? 200 : (status.aiEnabled ? 503 : 501);
    return res.status(httpStatus).json({
      success: status.connected,
      ...status,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      connected: false,
      aiEnabled: Boolean(ai),
      error: error.message || "Failed to determine AI status.",
    });
  }
});

// AI rate limiter (20 requests per minute)
const chatLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: "Too many requests. Please wait a moment before asking another question.",
  },
});

// Agricultural Knowledge System Prompt
const AGRICULTURAL_SYSTEM_INSTRUCTION = `
You are FieldShift AI, an elite Precision Agricultural Advisor and Agronomic Consultant.
Your mission is to provide accurate, science-based, and practical agricultural recommendations to farmers, agronomists, and land managers.

### Core Agronomic Competencies:
1. **Crop Rotation Strategy**:
   - Compare and recommend multi-season sequences (e.g. Cereal base like Wheat/Barley -> Legumes like Faba Bean, Chickpea, Lentil, Clover).
   - Biological nitrogen fixation: Symbiotic Rhizobium in legume nodules contributes an estimated ≈40-100 kg N/ha (approximate, context-dependent estimate; actual rates depend on soil moisture, Rhizobium strain, inoculant efficacy, and biomass; Source: USDA NRCS & FAO Plant Production Papers).
   - Soil health & synthetic fertilizer reduction: Cereal monoculture depletes soil nitrogen (≈ -30 to -60 kg N/ha/yr without replenishment).
   - Pest and pathogen cycle interruption: Breaking cereal root rot, take-all (Gaeumannomyces graminis), Fusarium crown rot, and cyst nematodes.
   - Climate-resilient alternative rotations: Sorghum, Pearl Millet, Sesame, Cowpea under drought/high heat, providing an estimated ≈20-35% irrigation reduction compared to continuous maize/cereal (Source: FAO Irrigation and Drainage Paper 56 crop evapotranspiration benchmarks).

2. **Smart Irrigation & Water Conservation**:
   - Evaluate soil moisture percentages:
     * Optimal field capacity for most loamy soils: ≈60-80% Available Water Capacity (AWC).
     * <50% indicates entering water deficit stress (irrigation trigger).
     * >85-90% risks soil saturation, root hypoxia, and Pythium/Phytophthora root rot.
     (Note: Exact volumetric moisture thresholds vary significantly by soil texture class—sand vs loam vs clay—and must be treated as approximate estimates unless calibrated with in-situ soil moisture sensor curves).
   - Irrigation systems & application efficiencies (Source: FAO Irrigation Manual):
     * Drip irrigation: ≈90-95% application efficiency.
     * Sprinkler irrigation: ≈75-80% application efficiency.
     * Flood / Furrow surface irrigation: ≈50-65% application efficiency.
   - Weather integration: If rain probability is high (>60%) or NASA POWER shows incoming precipitation, advise postponing irrigation to conserve water and prevent nitrate leaching.
   - Water conservation tactics: Night / early morning irrigation to minimize wind drift and evaporative loss, deficit irrigation during vegetative growth phases, and organic mulching.

3. **Crop Suitability & Critical Temperature Thresholds**:
   - Wheat (Triticum aestivum): Optimum anthesis/grain fill 18-24°C; severe heat stress and reduced yield when daily maximum exceeds 30-32°C during flowering (Source: CIMMYT Wheat Agrometeorology).
   - Maize (Zea mays): Vulnerable to tassel desiccation and pollen sterility when temperatures exceed 35°C during silking.
   - Recommend heat-tolerant cultivars and adjusted sowing windows matching regional agroclimatic patterns.

4. **Soil & Vegetation Indicators (NDVI interpretation)**:
   - Interpret NDVI (Normalized Difference Vegetation Index):
     * NDVI < 0.2: Bare soil, rock, fallow ground, or senescent residue.
     * NDVI 0.2 - 0.4: Emerging, sparse, or drought/nutrient-stressed canopy.
     * NDVI 0.4 - 0.6: Moderate crop canopy and average vegetative vigor.
     * NDVI > 0.6: Dense, vigorous, healthy crop canopy (Source: USGS & NASA Earth Observation Remote Sensing Guidelines).
   - Cross-reference NDVI with zone soil moisture to diagnose localized stress, drip emitter clogging, or salinity patches.

5. **Weather & Atmospheric Science (NASA Earth Observations)**:
   - Understand real NASA POWER agroclimatology parameters: T2M (2m Air Temperature °C), T2M_MAX, T2M_MIN, PRECTOTCORR (Precipitation mm/day), RH2M (Relative Humidity %), ALLSKY_SFC_SW_DWN (Solar Radiation MJ/m²/day).
   - Relate high solar radiation and low relative humidity (<30%) to high Vapor Pressure Deficit (VPD) and accelerated crop transpirational loss.

6. **Data Authenticity, Transparency, & Limitation Handling**:
   - **MANDATORY DATA AUDITING**:
     * If the payload includes 'nasaEarthObservations', you MUST identify atmospheric data (temperature, humidity, precipitation, solar radiation) as real NASA POWER satellite and meteorological observations.
     * If 'nasaEarthObservations' is missing or marked 'DEMO DATA', you MUST explicitly inform the user that all weather and field values are simulated demo readings.
     * If any specific observation parameter is missing, null, or out of range, explicitly state: "This measurement is currently unavailable; recommendations are based on regional agronomic baseline estimates."
     * In-field sensor values (zone soil moisture %, zone health %, zone NDVI) are simulated demonstration readings; NEVER state that they are live physical field sensors installed in the farmer's soil.
     * Clearly distinguish approximate empirical models from universal scientific laws. Every quantitative figure provided must be presented with appropriate context or labeled with "≈" as an estimate.
     * When farm data is insufficient to make a definitive diagnosis (e.g. unknown soil texture, unknown crop growth stage, unverified disease symptoms), explicitly state the data limitation and ask the farmer clarifying questions.

### Response Style & Guidelines:
- **Language**: Answer in the SAME language used by the user or specified in the request (fluent, professional Arabic for Arabic queries; clear, professional English for English queries).
- **Structure**:
  1. **Direct Assessment / Diagnosis**: Summarize current status based on verified farm and weather context.
  2. **Actionable Recommendations**: Bullet points with clear, practical steps (exact irrigation timing, rotation sequence, nutrient adjustments).
  3. **Risk Warnings & Water/Cost Impact**: Highlight heat, disease, or moisture risks with explicit uncertainty bounds.
  4. **Data Transparency & Next Steps**: State which data points are NASA vs demo vs missing, and suggest what the farmer should check next in the field.
- **Tone**: Professional, encouraging, respectful, and authoritative yet transparent and approachable for farmers.
`;

/**
 * Execute Gemini generation with model resilience and fallback
 */
async function generateAgriculturalAdvice({ message, farmContext, safeHistory, language }) {
  let farmInformation = "No specific farm context provided.";
  if (farmContext && typeof farmContext === "object") {
    try {
      farmInformation = JSON.stringify(farmContext, null, 2).slice(0, 8000);
    } catch {
      farmInformation = String(farmContext).slice(0, 4000);
    }
  }

  const promptLanguage = language === "ar" ? "Reply in fluent, natural Arabic (العربية)." : "Reply in English.";

  const contents = [
    ...safeHistory,
    {
      role: "user",
      parts: [
        {
          text: `
[FARM_DATA_CONTEXT]
${farmInformation}
[/FARM_DATA_CONTEXT]

[LANGUAGE_INSTRUCTION]
${promptLanguage}
[/LANGUAGE_INSTRUCTION]

[FARMER_QUESTION]
${message.trim()}
[/FARMER_QUESTION]
`.trim(),
        },
      ],
    },
  ];

  const candidates = getCandidateModels();
  const errors = [];

  for (const model of candidates) {
    try {
      console.log(`[Agricultural Advisor] Generating response using model: ${model}...`);
      const response = await withTimeout(
        ai.models.generateContent({
          model,
          contents,
          config: {
            systemInstruction: AGRICULTURAL_SYSTEM_INSTRUCTION,
            temperature: 0.4,
            maxOutputTokens: 2048,
          },
        }),
        35000,
        `Generation timed out on model ${model}`
      );

      if (response && response.text && response.text.trim().length > 0) {
        return {
          reply: response.text.trim(),
          modelUsed: model,
        };
      }
    } catch (err) {
      console.warn(`[Model Failure] Model "${model}" failed: ${err.message}`);
      errors.push(`${model}: ${err.message}`);

      const is429 =
        err.message.includes("429") ||
        err.message.includes("RESOURCE_EXHAUSTED") ||
        err.status === 429;
      const is503 =
        err.message.includes("503") ||
        err.message.includes("high demand") ||
        err.message.includes("UNAVAILABLE");

      if (is429) {
        // Immediately put model in cooldown for 30 minutes, instantly fallback without retry delay
        setModelCooldown(model, 30 * 60 * 1000, "Quota exhausted (429)");
        console.warn(`[Immediate Fallback] Model "${model}" quota exhausted (429). Instantly switching to next model without retry delay.`);
      } else if (is503) {
        // High demand spike - 1 minute cooldown, switch immediately
        setModelCooldown(model, 60 * 1000, "Demand spike (503)");
        console.warn(`[Immediate Fallback] Model "${model}" high demand (503). Instantly switching to next model.`);
      }
      // Continue loop to immediately try next model in candidate pool!
    }
  }

  throw new Error(`All available Gemini models failed: ${errors.join("; ")}`);
}

// Agricultural AI chat endpoint
app.post(["/api/chat", "/chat"], chatLimiter, async (req, res) => {
  try {
    if (!ai) {
      return res.status(503).json({
        success: false,
        error: "AI service is not configured. Missing GEMINI_API_KEY on the backend.",
      });
    }

    const { message, farmContext, history, language } = req.body || {};

    // Validate message
    if (typeof message !== "string" || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: "Please provide a valid question or message for the agricultural advisor.",
      });
    }

    if (message.length > 3000) {
      return res.status(400).json({
        success: false,
        error: "Message exceeds maximum allowed length of 3000 characters.",
      });
    }

    // Validate and format conversation history
    const safeHistory = Array.isArray(history)
      ? history
        .filter(
          (item) =>
            item &&
            ["user", "model"].includes(item.role) &&
            typeof item.text === "string" &&
            item.text.trim().length > 0
        )
        .slice(-10)
        .map((item) => ({
          role: item.role,
          parts: [{ text: item.text.slice(0, 2500) }],
        }))
      : [];

    const result = await generateAgriculturalAdvice({
      message,
      farmContext,
      safeHistory,
      language,
    });

    return res.json({
      success: true,
      reply: result.reply,
      model: result.modelUsed,
    });
  } catch (error) {
    console.error("Agricultural advisor error:", error.message);

    const isOverload =
      error.message.includes("503") ||
      error.message.includes("high demand") ||
      error.message.includes("UNAVAILABLE") ||
      error.message.includes("RESOURCE_EXHAUSTED");

    const statusCode = isOverload ? 503 : 500;
    const userMessage = isOverload
      ? "The agricultural AI service is experiencing high demand. Please try again in a few moments."
      : "The agricultural advisor could not process your request at this time.";

    return res.status(statusCode).json({
      success: false,
      error: userMessage,
      detail: error.message,
    });
  }
});

// Centralized error handling
app.use((err, req, res, next) => {
  if (err.message === "Origin not allowed.") {
    return res.status(403).json({
      success: false,
      error: "CORS origin not allowed.",
    });
  }

  console.error("Server error:", err.message);

  return res.status(500).json({
    success: false,
    error: "Internal server error.",
  });
});

// Start server
const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`FieldShift AI Backend running on port ${PORT}`);
  console.log(`Configured Model: ${CONFIGURED_MODEL}`);
  console.log(`Fallback Models: ${FALLBACK_MODELS.join(", ")}`);
  console.log(`Gemini AI: ${ai ? "Initialized" : "Disabled (No Key)"}`);
});

export { app, server };
