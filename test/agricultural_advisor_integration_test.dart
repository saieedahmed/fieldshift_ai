import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fieldshift_ai/data/mock/mock_farm_data.dart';
import 'package:fieldshift_ai/data/models/nasa_observation.dart';
import 'package:fieldshift_ai/data/repositories/agricultural_advisor_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AgriculturalAdvisorService Integration & Normalization', () {
    test('normalizes base url to /api/chat automatically', () async {
      http.Request? capturedRequest;
      final service = AgriculturalAdvisorService(
        endpoint: 'http://localhost:3000',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode({'reply': 'Irrigate lightly.'}), 200);
        }),
      );
      addTearDown(service.close);

      final reply = await service.ask(
        question: 'Should I irrigate?',
        languageCode: 'en',
        farm: MockFarmData.farm,
        history: const [],
      );

      expect(reply, 'Irrigate lightly.');
      expect(capturedRequest?.url.path, '/api/chat');
    });

    test('preserves explicitly defined /chat or custom endpoints', () async {
      http.Request? capturedRequest;
      final service = AgriculturalAdvisorService(
        endpoint: 'https://custom-advisor.org/chat',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'reply': 'Crop rotation advice.'}),
            200,
          );
        }),
      );
      addTearDown(service.close);

      final reply = await service.ask(
        question: 'Suggest rotation',
        languageCode: 'en',
        farm: MockFarmData.farm,
        history: const [],
      );

      expect(reply, 'Crop rotation advice.');
      expect(capturedRequest?.url.path, '/chat');
    });

    test(
      'parses server error JSON and surfaces detailed backend message',
      () async {
        final service = AgriculturalAdvisorService(
          endpoint: 'http://localhost:3000/api/chat',
          client: MockClient((request) async {
            return http.Response(
              jsonEncode({
                'success': false,
                'error':
                    'The agricultural AI service is experiencing high demand.',
              }),
              503,
            );
          }),
        );
        addTearDown(service.close);

        expect(
          () => service.ask(
            question: 'Hello',
            languageCode: 'en',
            farm: MockFarmData.farm,
            history: const [],
          ),
          throwsA(
            predicate<AdvisorServiceException>(
              (e) => e.message.contains('high demand'),
            ),
          ),
        );
      },
    );

    test(
      'enriches farmContext with real NASA data and crop rotation options',
      () async {
        http.Request? capturedRequest;
        final service = AgriculturalAdvisorService(
          endpoint: 'http://localhost:3000/api/chat',
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({'reply': 'NASA-informed advice.'}),
              200,
            );
          }),
        );
        addTearDown(service.close);

        final now = DateTime.now();
        final nasaClimate = NasaDailyClimate(
          status: NasaDataStatus.available,



          
          latestTemperature: 29.5,
          latestTempMax: 34.0,
          latestTempMin: 21.0,
          latestHumidity: 42.0,
          latestPrecipitation: 0.0,
          latestSolarRadiation: 22.5,
          dates: [now.toIso8601String()],
          temperatureHistory: const [29.5],
          precipitationHistory: const [1.2],
        );

        final reply = await service.ask(
          question: 'Analyze climate risk',
          languageCode: 'ar',
          farm: MockFarmData.farm,
          history: const [],
          nasaClimate: nasaClimate,
        );

        expect(reply, 'NASA-informed advice.');
        final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
        final context = body['farmContext'] as Map<String, dynamic>;

        expect(context['dataSource'], contains('NASA POWER'));
        expect(context['dataIsSimulated'], isFalse);

        final nasaObs =
            context['nasaEarthObservations'] as Map<String, dynamic>;
        expect(nasaObs['status'], 'REAL_NASA_OBSERVATIONS');
        expect(nasaObs['tempMaxC'], 34.0);
        expect(nasaObs['solarRadiationMjM2Day'], 22.5);

        final rotations = context['cropRotationStrategies'] as List<dynamic>;
        expect(rotations, isNotEmpty);
        expect(rotations.any((r) => r['id'] == 'strategy_legume'), isTrue);
      },
    );

    test('automatically resolves default endpoint based on environment', () {
      final defaultService = AgriculturalAdvisorService();
      addTearDown(defaultService.close);

      expect(defaultService.isConfigured, isTrue);
      expect(defaultService.endpointUrl, contains('3000/api/chat'));
    });

    test('resolves Android emulator loopback host when platform is Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final service = AgriculturalAdvisorService();
        addTearDown(service.close);
        expect(service.endpointUrl, 'http://10.0.2.2:3000/api/chat');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('strictly excludes API key and sensitive credentials from client requests', () async {
      http.Request? capturedRequest;
      final service = AgriculturalAdvisorService(
        endpoint: 'http://127.0.0.1:3000/api/chat',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode({'reply': 'Safe.'}), 200);
        }),
      );
      addTearDown(service.close);

      await service.ask(
        question: 'Security check',
        languageCode: 'en',
        farm: MockFarmData.farm,
        history: const [],
      );

      final payloadString = capturedRequest!.body;
      expect(payloadString.toLowerCase(), isNot(contains('apikey')));
      expect(payloadString.toLowerCase(), isNot(contains('gemini_api_key')));
      expect(capturedRequest!.headers.keys.map((k) => k.toLowerCase()), isNot(contains('x-goog-api-key')));
    });
  });
}
