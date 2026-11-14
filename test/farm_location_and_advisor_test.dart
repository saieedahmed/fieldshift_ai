import 'dart:convert';

import 'package:fieldshift_ai/data/mock/mock_farm_data.dart';
import 'package:fieldshift_ai/data/models/farm_location.dart';
import 'package:fieldshift_ai/data/repositories/agricultural_advisor_service.dart';
import 'package:fieldshift_ai/data/repositories/farm_location_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('farm location is saved and restored with its coordinates', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesFarmLocationRepository();
    const location = FarmLocation(
      countryCode: 'KE',
      countryName: 'Kenya',
      localizedCountryName: 'كينيا',
      placeName: 'Nairobi',
      localizedPlaceName: 'نيروبي',
      latitude: -1.2864,
      longitude: 36.8172,
    );

    await repository.save(location);

    final restored = await repository.load();
    expect(restored?.countryCode, location.countryCode);
    expect(restored?.placeName, location.placeName);
    expect(restored?.localizedPlaceName, location.localizedPlaceName);
    expect(restored?.latitude, location.latitude);
    expect(restored?.longitude, location.longitude);
  });

  test(
    'advisor request includes farm context and demo-data disclosure',
    () async {
      http.Request? capturedRequest;
      final service = AgriculturalAdvisorService(
        endpoint: 'https://advisor.example.test/chat',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'reply': 'Check soil moisture.'}),
            200,
          );
        }),
      );
      addTearDown(service.close);

      final reply = await service.ask(
        question: 'How should I irrigate?',
        languageCode: 'en',
        farm: MockFarmData.farm,
        history: const [],
      );

      final payload = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      final farmContext = payload['farmContext'] as Map<String, dynamic>;
      final location = farmContext['location'] as Map<String, dynamic>;
      expect(reply, 'Check soil moisture.');
      expect(location['countryCode'], 'EG');
      expect(location['latitude'], 30.58);
      expect(farmContext['dataSource'], 'DEMO DATA');
      expect(farmContext['dataIsSimulated'], isTrue);
      expect(capturedRequest!.body, isNot(contains('apiKey')));
      expect(capturedRequest!.headers, isNot(contains('x-goog-api-key')));
    },
  );

  test('advisor refuses to send requests without a configured proxy', () {
    final service = AgriculturalAdvisorService(endpoint: '');
    addTearDown(service.close);
    expect(
      () => service.ask(
        question: 'What should I plant?',
        languageCode: 'en',
        farm: MockFarmData.farm,
        history: const [],
      ),
      throwsA(isA<AdvisorConfigurationException>()),
    );
  });
}
