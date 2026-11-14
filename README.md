# FieldShift AI

Flutter application for farm monitoring, analysis, irrigation, and agricultural
advice. The existing Living Landscape and demo farm remain available.

## Farm location

Open **Settings → Change farm location** to choose any country, search for a
city or region, and set the pin on the interactive OpenStreetMap. The selected
latitude and longitude are saved on the device and used in analysis views and
the agricultural advisor's farm context.

The initial farm in El Meselha, Menoufia, Egypt is an editable demo location,
not a requirement that users be in Egypt. Map tiles and place search require an
internet connection. The map uses OpenStreetMap tiles and Nominatim search;
follow their attribution and usage policies before production deployment.

## Gemini advisor setup

The Flutter app **does not contain a Gemini API key** and never calls Gemini
directly. It sends the question and relevant farm context to a backend proxy.
Until a proxy is configured, the chat reports that it is not connected.

Configure the proxy URL at build/run time:

```powershell
flutter run --dart-define=ADVISOR_API_URL=https://your-backend.example/api/advisor
```

For the existing local Node proxy, the route is `/api/chat`. On the Android
emulator, use its host-machine address:

```powershell
flutter run --dart-define=ADVISOR_API_URL=http://10.0.2.2:3000/api/chat
```

For a physical device, use the development machine's reachable LAN address
instead of `10.0.2.2`. The backend reads `GEMINI_API_KEY` server-side; never
copy its `.env` value into Flutter or share it with clients.

`ADVISOR_API_URL` is an endpoint, not a secret. The backend should keep
`GEMINI_API_KEY` in a server-side environment variable or secret manager, call
Gemini, and return JSON in this shape:

```json
{"reply":"Your Arabic or English agricultural answer"}
```

The request includes `message`, `language`, conversation `history`,
`systemInstruction`, and `farmContext` with location, crop, area, and current
demo readings. Implement authentication, input limits, rate limiting, and
appropriate privacy controls in the proxy before production use. Never put the
Gemini key in Dart code, `--dart-define`, app assets, or a committed file. Use
HTTPS for production; plain HTTP endpoints are accepted only in debug builds
for local proxy testing.

The current local proxy allows unrestricted CORS and has no authentication or
rate limiting; do not expose it publicly until those controls are added.

The current crop, soil, climate, and health readings are explicitly marked
**DEMO DATA**. They are illustrative values, not live sensor, weather, or NASA
data. The advisor receives that disclosure with every request.

## Validation

```powershell
flutter analyze
flutter test
flutter build apk --release
```
