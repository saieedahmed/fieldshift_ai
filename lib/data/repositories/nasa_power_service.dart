import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/nasa_observation.dart';

/// Service responsible for querying official NASA POWER Agroclimatology Daily API
/// with robust error handling, fill-value filtering, coordinate validation, and caching.
class NasaPowerService {
  NasaPowerService({http.Client? client, SharedPreferences? preferences})
    : _providedClient = client,
      _providedPreferences = preferences;

  static const String _baseUrl =
      'https://power.larc.nasa.gov/api/temporal/daily/point';
  static const Duration _cacheTtl = Duration(hours: 8);
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client? _providedClient;
  http.Client? _client;
  final SharedPreferences? _providedPreferences;
  Future<SharedPreferences>? _preferencesFuture;

  // In-memory cache for fast tab-switching
  static final Map<String, _CachedEntry> _memoryCache = {};

  http.Client get _httpClient => _client ??= _providedClient ?? http.Client();

  Future<SharedPreferences> _getPreferences() {
    final cached = _preferencesFuture;
    if (cached != null) return cached;
    final provided = _providedPreferences;
    final preferences = provided != null
        ? Future.value(provided)
        : SharedPreferences.getInstance();
    _preferencesFuture = preferences;
    return preferences;
  }

  void close() => _client?.close();

  /// Retrieve NASA POWER daily agroclimatology observations for the given coordinate.
  Future<NasaDailyClimate> fetchDailyClimate({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    // 1. Validate coordinates
    if (!_isValidCoordinates(latitude, longitude)) {
      return const NasaDailyClimate(
        status: NasaDataStatus.error,
        errorMessage: 'Invalid coordinates. Latitude must be -90..90 and Longitude -180..180.',
      );
    }

    final cacheKey = _buildCacheKey(latitude, longitude);

    // 2. Check in-memory cache
    if (!forceRefresh && _memoryCache.containsKey(cacheKey)) {
      final entry = _memoryCache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheTtl) {
        return entry.climate;
      }
    }

    // 3. Check persistent SharedPreferences cache
    if (!forceRefresh) {
      final cachedClimate = await _loadPersistentCache(cacheKey);
      if (cachedClimate != null) {
        _memoryCache[cacheKey] = _CachedEntry(
          timestamp: cachedClimate.retrievedAt ?? DateTime.now(),
          climate: cachedClimate,
        );
        if (DateTime.now().difference(cachedClimate.retrievedAt ?? DateTime.now()) < _cacheTtl) {
          return cachedClimate;
        }
      }
    }

    // 4. Compute valid historical date window
    // NASA POWER daily reanalysis has a typical processing lag of 3 to 5 days.
    // We request a 12-day window ending 4 days ago to ensure high probability of processed observations.
    final now = DateTime.now().toUtc();
    final endDate = now.subtract(const Duration(days: 4));
    final startDate = endDate.subtract(const Duration(days: 11));

    final startStr = _formatDate(startDate);
    final endStr = _formatDate(endDate);

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'parameters':
            'T2M,T2M_MAX,T2M_MIN,PRECTOTCORR,RH2M,ALLSKY_SFC_SW_DWN',
        'community': 'ag',
        'longitude': longitude.toStringAsFixed(4),
        'latitude': latitude.toStringAsFixed(4),
        'start': startStr,
        'end': endStr,
        'format': 'JSON',
      },
    );

    try {
      final response = await _httpClient
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'FieldShiftAI/1.0 (NASA Space Apps Challenge 2026)',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return _fallbackToCacheOrError(
          cacheKey,
          'NASA POWER server returned status ${response.statusCode}.',
        );
      }

      final climate = parseNasaResponse(
        responseBody: response.body,
        latitude: latitude,
        longitude: longitude,
      );

      // Save to memory and persistent cache
      _memoryCache[cacheKey] = _CachedEntry(
        timestamp: DateTime.now(),
        climate: climate,
      );
      await _savePersistentCache(cacheKey, climate);

      return climate;
    } catch (error) {
      debugPrint('NASA POWER API request error: $error');
      return _fallbackToCacheOrError(
        cacheKey,
        'Network error contacting NASA POWER service.',
      );
    }
  }

  /// Parse official NASA POWER JSON response, discarding -999.0 fill values
  NasaDailyClimate parseNasaResponse({
    required String responseBody,
    required double latitude,
    required double longitude,
  }) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid NASA POWER JSON response.');
    }

    final properties = decoded['properties'] as Map<String, dynamic>?;
    final parameters = properties?['parameter'] as Map<String, dynamic>?;
    final header = decoded['header'] as Map<String, dynamic>?;
    final fillValue = (header?['fill_value'] as num?)?.toDouble() ?? -999.0;
    final sourcesList = header?['sources'] as List<dynamic>?;
    final sourceName = sourcesList != null && sourcesList.isNotEmpty
        ? 'NASA POWER (${sourcesList.join('/')})'
        : 'NASA POWER (GEOS-IT / MERRA-2)';

    if (parameters == null) {
      return const NasaDailyClimate(
        status: NasaDataStatus.missing,
        errorMessage: 'NASA POWER response contained no parameter observations.',
      );
    }

    final t2mMap = parameters['T2M'] as Map<String, dynamic>? ?? {};
    final t2mMaxMap = parameters['T2M_MAX'] as Map<String, dynamic>? ?? {};
    final t2mMinMap = parameters['T2M_MIN'] as Map<String, dynamic>? ?? {};
    final precipMap = parameters['PRECTOTCORR'] as Map<String, dynamic>? ?? {};
    final rhMap = parameters['RH2M'] as Map<String, dynamic>? ?? {};
    final solarMap = parameters['ALLSKY_SFC_SW_DWN'] as Map<String, dynamic>? ?? {};

    // Collect all date keys sorted chronologically
    final allDateKeys = t2mMap.keys.toList()..sort();

    final records = <NasaDailyRecord>[];

    for (final dateKey in allDateKeys) {
      final date = _parseDateKey(dateKey);
      if (date == null) continue;

      final t2m = _cleanValue(t2mMap[dateKey], fillValue);
      final t2mMax = _cleanValue(t2mMaxMap[dateKey], fillValue);
      final t2mMin = _cleanValue(t2mMinMap[dateKey], fillValue);
      final precip = _cleanValue(precipMap[dateKey], fillValue);
      final rh = _cleanValue(rhMap[dateKey], fillValue);
      final solar = _cleanValue(solarMap[dateKey], fillValue);

      // Only add record if at least one parameter is valid (not fill value)
      if (t2m != null || precip != null || rh != null || solar != null) {
        records.add(
          NasaDailyRecord(
            date: date,
            temperature: t2m,
            tempMax: t2mMax,
            tempMin: t2mMin,
            precipitation: precip,
            humidity: rh,
            solarRadiation: solar,
          ),
        );
      }
    }

    if (records.isEmpty) {
      return const NasaDailyClimate(
        status: NasaDataStatus.missing,
        errorMessage: 'All observations in the requested period are missing (-999).',
      );
    }

    // Extract valid historical series for temperature and precipitation
    final validTempRecords = records.where((r) => r.temperature != null).toList();
    final validPrecipRecords = records.where((r) => r.precipitation != null).toList();

    // Take up to 7 most recent days for trend chart
    final recentRecords = records.length > 7
        ? records.sublist(records.length - 7)
        : records;

    final tempHistory = recentRecords
        .map((r) => r.temperature ?? 0.0)
        .toList(growable: false);

    final precipHistory = recentRecords
        .map((r) => r.precipitation ?? 0.0)
        .toList(growable: false);

    final dateLabels = recentRecords
        .map((r) => '${r.date.month}/${r.date.day}')
        .toList(growable: false);

    final latestRecord = records.last;

    return NasaDailyClimate(
      status: NasaDataStatus.available,
      dailyRecords: records,
      temperatureHistory: tempHistory,
      precipitationHistory: precipHistory,
      dates: dateLabels,
      latestTemperature: latestRecord.temperature ?? validTempRecords.lastOrNull?.temperature,
      latestTempMax: latestRecord.tempMax ?? validTempRecords.lastOrNull?.tempMax,
      latestTempMin: latestRecord.tempMin ?? validTempRecords.lastOrNull?.tempMin,
      latestHumidity: latestRecord.humidity,
      latestPrecipitation: latestRecord.precipitation ?? validPrecipRecords.lastOrNull?.precipitation,
      latestSolarRadiation: latestRecord.solarRadiation,
      retrievedAt: DateTime.now(),
      startDate: records.first.date,
      endDate: records.last.date,
      dataSource: sourceName,
      isFromCache: false,
    );
  }

  /// Discard fill values (-999.0) and corrupted bounds
  double? _cleanValue(dynamic raw, double fillValue) {
    if (raw == null) return null;
    final val = (raw as num).toDouble();
    if ((val - fillValue).abs() < 0.1 || val <= -500.0) {
      return null;
    }
    return val;
  }

  bool _isValidCoordinates(double lat, double lon) =>
      lat >= -90.0 && lat <= 90.0 && lon >= -180.0 && lon <= 180.0;

  String _formatDate(DateTime d) =>
      '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

  DateTime? _parseDateKey(String key) {
    if (key.length != 8) return null;
    final y = int.tryParse(key.substring(0, 4));
    final m = int.tryParse(key.substring(4, 6));
    final d = int.tryParse(key.substring(6, 8));
    if (y == null || m == null || d == null) return null;
    return DateTime.utc(y, m, d);
  }

  String _buildCacheKey(double lat, double lon) =>
      'nasa_power_cache_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  Future<NasaDailyClimate?> _loadPersistentCache(String key) async {
    try {
      final prefs = await _getPreferences();
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return NasaDailyClimate.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _savePersistentCache(String key, NasaDailyClimate climate) async {
    try {
      final prefs = await _getPreferences();
      await prefs.setString(key, jsonEncode(climate.toJson()));
    } catch (_) {}
  }

  Future<NasaDailyClimate> _fallbackToCacheOrError(
    String key,
    String defaultError,
  ) async {
    final cached = await _loadPersistentCache(key);
    if (cached != null && cached.hasValidData) {
      return NasaDailyClimate(
        status: NasaDataStatus.cached,
        dailyRecords: cached.dailyRecords,
        temperatureHistory: cached.temperatureHistory,
        precipitationHistory: cached.precipitationHistory,
        dates: cached.dates,
        latestTemperature: cached.latestTemperature,
        latestTempMax: cached.latestTempMax,
        latestTempMin: cached.latestTempMin,
        latestHumidity: cached.latestHumidity,
        latestPrecipitation: cached.latestPrecipitation,
        latestSolarRadiation: cached.latestSolarRadiation,
        retrievedAt: cached.retrievedAt,
        startDate: cached.startDate,
        endDate: cached.endDate,
        dataSource: cached.dataSource,
        temporalResolution: cached.temporalResolution,
        spatialResolution: cached.spatialResolution,
        isFromCache: true,
        errorMessage: defaultError,
        uncertaintyNotice: cached.uncertaintyNotice,
      );
    }
    return NasaDailyClimate(
      status: NasaDataStatus.error,
      errorMessage: defaultError,
    );
  }
}

class _CachedEntry {
  _CachedEntry({required this.timestamp, required this.climate});
  final DateTime timestamp;
  final NasaDailyClimate climate;
}

