import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class FarmLocationSearchResult {
  const FarmLocationSearchResult({required this.name, required this.point});

  final String name;
  final LatLng point;
}

class FarmLocationSearchService {
  FarmLocationSearchService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  void close() => _client.close();

  Future<List<FarmLocationSearchResult>> search({
    required String place,
    required String countryCode,
    required String languageCode,
  }) async {
    final query = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': '$place, $countryCode',
      'countrycodes': countryCode.toLowerCase(),
      'format': 'jsonv2',
      'limit': '5',
      'accept-language': languageCode,
    });
    final response = await _client
        .get(
          query,
          headers: const {
            'User-Agent': 'FieldShiftAI/1.0 farm-location-search',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw FarmLocationSearchException(
        'Location search failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Location search returned invalid data.');
    }

    return decoded
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'Location search returned an invalid item.',
            );
          }
          final latitude = double.tryParse(item['lat'] as String? ?? '');
          final longitude = double.tryParse(item['lon'] as String? ?? '');
          final name = item['display_name'] as String?;
          if (latitude == null ||
              longitude == null ||
              name == null ||
              latitude < -90 ||
              latitude > 90 ||
              longitude < -180 ||
              longitude > 180) {
            throw const FormatException(
              'Location search returned invalid fields.',
            );
          }
          return FarmLocationSearchResult(
            name: name,
            point: LatLng(latitude, longitude),
          );
        })
        .toList(growable: false);
  }
}

class FarmLocationSearchException implements Exception {
  const FarmLocationSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}
