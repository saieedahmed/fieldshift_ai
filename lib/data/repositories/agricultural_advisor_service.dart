import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/farm_data.dart';
import '../models/nasa_observation.dart';

class AgriculturalAdvisorService {
  AgriculturalAdvisorService({http.Client? client, String? endpoint})
    : _providedClient = client,
      _endpoint = endpoint ?? const String.fromEnvironment('ADVISOR_API_URL');

  final http.Client? _providedClient;
  http.Client? _client;
  final String _endpoint;

  bool get isConfigured => _endpoint.trim().isNotEmpty;

  http.Client get _httpClient => _client ??= _providedClient ?? http.Client();

  void close() => _client?.close();

  Future<String> ask({
    required String question,
    required String languageCode,
    required FarmData farm,
    required List<Map<String, String>> history,
    NasaDailyClimate? nasaClimate,
  }) async {
    final endpoint = _endpoint.trim();
    if (endpoint.isEmpty) throw const AdvisorConfigurationException();
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && !kDebugMode)) {
      throw const AdvisorConfigurationException();
    }

    final hasNasaData = nasaClimate != null && nasaClimate.hasValidData;

    final response = await _httpClient
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
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
              'dataSource': hasNasaData
                  ? 'HYBRID: NASA POWER (climate) + DEMO DATA (soil/crop)'
                  : 'DEMO DATA',
              'dataIsSimulated': !hasNasaData,
            },
            'systemInstruction':
                'You are an agricultural advisor. Reply in ${languageCode == 'ar' ? 'Arabic' : 'English'}. '
                'Help with crop selection, irrigation, soil, plant health, '
                'pests and diseases, climate, and farm productivity. '
                'Use the supplied farm context when relevant. '
                '${hasNasaData ? 'Atmospheric readings (temperature, precipitation, humidity, solar radiation) are real NASA POWER observations. Soil moisture and NDVI remain simulated demo readings.' : 'The farm readings are DEMO DATA, not live sensor, weather, or NASA data.'} '
                'State limitations clearly, do not claim to have live in-situ sensor data, and ask for missing details instead of guessing.',
          }),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdvisorServiceException(
        'Advisor service returned status ${response.statusCode}.',
      );
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
