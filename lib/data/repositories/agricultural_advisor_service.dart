import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/crop_rotation.dart';
import '../models/farm_data.dart';
import '../models/nasa_observation.dart';
import 'crop_rotation_repository.dart';

class AgriculturalAdvisorService {
  AgriculturalAdvisorService({http.Client? client, String? endpoint})
    : _providedClient = client,
      _endpoint = _resolveEndpoint(endpoint);

  final http.Client? _providedClient;
  http.Client? _client;
  final String _endpoint;

  static String _resolveEndpoint(String? customEndpoint) {
    // If explicitly specified
    if (customEndpoint != null) {
      final trimmed = customEndpoint.trim();
      if (trimmed.isEmpty) return ''; // Explicitly unconfigured
      return _normalizeUrl(trimmed);
    }

    // Check compile-time environment variable
    const envUrl = String.fromEnvironment('ADVISOR_API_URL');
    if (envUrl.trim().isNotEmpty) {
      return _normalizeUrl(envUrl.trim());
    }

    // In release mode without an explicit endpoint, do not default to insecure local HTTP
    if (kReleaseMode) {
      return '';
    }

    // In development/debug mode, automatically select development host based on platform
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator host loopback address
      return 'http://10.0.2.2:3000/api/chat';
    }
    // Desktop (Windows, macOS, Linux), iOS Simulator, and Web
    return 'http://127.0.0.1:3000/api/chat';
  }

  static String _normalizeUrl(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null) return raw;
    // If user provided a base URL without path, default to /api/chat
    if (uri.path.isEmpty || uri.path == '/') {
      return uri.replace(path: '/api/chat').toString();
    }
    return raw;
  }

  bool get isConfigured => _endpoint.trim().isNotEmpty;

  String get endpointUrl => _endpoint;

  http.Client get _httpClient => _client ??= _providedClient ?? http.Client();

  void close() => _client?.close();

  Future<String> ask({
    required String question,
    required String languageCode,
    required FarmData farm,
    required List<Map<String, String>> history,
    NasaDailyClimate? nasaClimate,
    List<CropRotationStrategy>? rotationStrategies,
  }) async {
    final endpoint = _endpoint.trim();
    if (endpoint.isEmpty) throw const AdvisorConfigurationException();
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty) {
      throw const AdvisorConfigurationException();
    }

    // Disallow insecure HTTP connections in release builds
    if (kReleaseMode && uri.scheme != 'https') {
      throw const AdvisorConfigurationException();
    }

    final hasNasaData = nasaClimate != null && nasaClimate.hasValidData;
    final strategies =
        rotationStrategies ??
        const CropRotationRepository().getRotationStrategies(
          nasaClimate: nasaClimate,
        );

    final requestBody = jsonEncode({
      'message': question,
      'language': languageCode,
      'history': history,
      'farmContext': {
        'location': {
          'country': farm.location.countryName,
          'countryCode': farm.location.countryCode,
          'place': farm.location.placeName,
          'latitude': farm.location.latitude,
          'longitude': farm.location.longitude,
        },
        'crop': farm.cropNameKey,
        'areaHectares': farm.areaHectares,
        'conditions': {
          'temperatureC': farm.temperatureC,
          'humidityPercent': farm.humidityPercent,
          'rainProbability': farm.rainProbability,
          'soilMoisturePercent': farm.zones
              .map((zone) => zone.moisturePercent)
              .toList(growable: false),
          'cropHealthPercent': farm.zones
              .map((zone) => zone.healthPercent)
              .toList(growable: false),
          'ndvi': farm.zones.map((zone) => zone.ndvi).toList(growable: false),
        },
        if (hasNasaData)
          'nasaEarthObservations': {
            'dataSource': nasaClimate.dataSource,
            'status': 'REAL_NASA_OBSERVATIONS',
            'recentTemperatureC': nasaClimate.latestTemperature,
            'tempMaxC': nasaClimate.latestTempMax,
            'tempMinC': nasaClimate.latestTempMin,
            'relativeHumidityPercent': nasaClimate.latestHumidity,
            'precipitationMmDay': nasaClimate.latestPrecipitation,
            'cumulative7DayPrecipitationMm':
                nasaClimate.cumulativePrecipitationMm,
            'solarRadiationMjM2Day': nasaClimate.latestSolarRadiation,
            'uncertaintyNotice': nasaClimate.uncertaintyNotice,
          },
        'cropRotationStrategies': strategies
            .map(
              (s) => {
                'id': s.id,
                'name': s.nameKey,
                'crops': s.sequenceCropsKeys,
                'seasonDurationMonths': s.seasonDurationMonths,
                'waterSavingsPercent': s.estimatedWaterSavingsPercent,
                'nitrogenImpactKgPerHa': s.estimatedNitrogenImpactKgPerHa,
                'heatToleranceIndex': s.heatToleranceIndex,
                'isCurrent': s.isCurrentPractice,
              },
            )
            .toList(growable: false),
        'dataSource': hasNasaData
            ? 'HYBRID: NASA POWER (climate) + DEMO DATA (soil/crop)'
            : 'DEMO DATA',
        'dataIsSimulated': !hasNasaData,
      },
      'systemInstruction':
          'You are FieldShift AI, an elite precision agricultural advisor. Reply in ${languageCode == 'ar' ? 'Arabic' : 'English'}. '
          'Help with crop rotation, smart irrigation, soil condition, crop health, '
          'pest/pathogen risks, climate resilience, and farm productivity. '
          'Use the supplied farm context when relevant. '
          '${hasNasaData ? 'Atmospheric readings (temperature, precipitation, humidity, solar radiation) are real NASA POWER satellite/meteorological observations. Soil moisture and NDVI remain simulated demo readings.' : 'All farm readings are DEMO DATA, not live physical field sensor or NASA data.'} '
          'State data limitations clearly: treat all quantitative figures as approximate context-dependent estimates (≈) unless scientifically calibrated, never claim simulated demo readings are live in-situ soil sensors, identify any missing or unavailable observations, and ask for missing agricultural details instead of guessing.',
    });

    const maxAttempts = 2;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final response = await _httpClient
            .post(
              uri,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: requestBody,
            )
            .timeout(const Duration(seconds: 40));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          String errorMessage =
              'Advisor service returned status ${response.statusCode}.';
          try {
            final decodedBody = jsonDecode(response.body);
            if (decodedBody is Map<String, dynamic> &&
                decodedBody['error'] is String) {
              errorMessage = decodedBody['error'] as String;
            }
          } catch (_) {}

          // If upstream temporary demand spike, retry once
          if (response.statusCode == 503 && attempt < maxAttempts) {
            await Future<void>.delayed(const Duration(milliseconds: 1500));
            continue;
          }

          throw AdvisorServiceException(errorMessage);
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const AdvisorServiceException(
            'Advisor service returned an invalid response.',
          );
        }
        final reply = decoded['reply'];
        if (reply is! String || reply.trim().isEmpty) {
          throw const AdvisorServiceException(
            'Advisor service returned an empty reply.',
          );
        }
        return reply.trim();
      } on SocketException catch (e) {
        if (attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(milliseconds: 1000));
          continue;
        }
        throw AdvisorServiceException('Cannot connect to AI service: ${e.message}');
      } on TimeoutException {
        if (attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(milliseconds: 1000));
          continue;
        }
        throw const AdvisorServiceException(
          'Request timed out. The agricultural advisor service took too long to reply.',
        );
      } on http.ClientException catch (e) {
        if (attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(milliseconds: 1000));
          continue;
        }
        throw AdvisorServiceException('Network error: ${e.message}');
      }
    }

    throw const AdvisorServiceException('Advisor service unavailable.');
  }
}

class AdvisorConfigurationException implements Exception {
  const AdvisorConfigurationException();
}

class AdvisorServiceException implements Exception {
  const AdvisorServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
