import 'package:shared_preferences/shared_preferences.dart';

import '../models/farm_location.dart';

abstract interface class FarmLocationRepository {
  Future<FarmLocation?> load();
  Future<void> save(FarmLocation location);
}

class SharedPreferencesFarmLocationRepository
    implements FarmLocationRepository {
  SharedPreferencesFarmLocationRepository({SharedPreferences? preferences})
    : _providedPreferences = preferences;

  static const _countryCodeKey = 'farm_location_country_code';
  static const _countryNameKey = 'farm_location_country_name';
  static const _localizedCountryNameKey = 'farm_location_localized_country';
  static const _placeNameKey = 'farm_location_place_name';
  static const _localizedPlaceNameKey = 'farm_location_localized_place_name';
  static const _latitudeKey = 'farm_location_latitude';
  static const _longitudeKey = 'farm_location_longitude';

  final SharedPreferences? _providedPreferences;
  Future<SharedPreferences>? _preferencesFuture;

  Future<SharedPreferences> _getPreferences() {
    final cached = _preferencesFuture;
    if (cached != null) return cached;
    final provided = _providedPreferences;
    final preferences = provided == null
        ? SharedPreferences.getInstance()
        : Future.value(provided);
    _preferencesFuture = preferences;
    return preferences;
  }

  @override
  Future<FarmLocation?> load() async {
    final preferences = await _getPreferences();
    final countryCode = preferences.getString(_countryCodeKey);
    if (countryCode == null) return null;

    final countryName = preferences.getString(_countryNameKey);
    final localizedCountryName = preferences.getString(
      _localizedCountryNameKey,
    );
    final placeName = preferences.getString(_placeNameKey);
    final localizedPlaceName = preferences.getString(_localizedPlaceNameKey);
    final latitude = preferences.getDouble(_latitudeKey);
    final longitude = preferences.getDouble(_longitudeKey);
    if (countryName == null ||
        localizedCountryName == null ||
        placeName == null ||
        localizedPlaceName == null ||
        latitude == null ||
        longitude == null ||
        !_isValidCoordinate(latitude, longitude)) {
      throw const FormatException('Saved farm location is incomplete.');
    }

    return FarmLocation(
      countryCode: countryCode,
      countryName: countryName,
      localizedCountryName: localizedCountryName,
      placeName: placeName,
      localizedPlaceName: localizedPlaceName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<void> save(FarmLocation location) async {
    if (!_isValidCoordinate(location.latitude, location.longitude)) {
      throw ArgumentError.value(location, 'location', 'Invalid coordinates.');
    }

    final preferences = await _getPreferences();
    await preferences.setString(_countryCodeKey, location.countryCode);
    await preferences.setString(_countryNameKey, location.countryName);
    await preferences.setString(
      _localizedCountryNameKey,
      location.localizedCountryName,
    );
    await preferences.setString(_placeNameKey, location.placeName);
    await preferences.setString(
      _localizedPlaceNameKey,
      location.localizedPlaceName,
    );
    await preferences.setDouble(_latitudeKey, location.latitude);
    await preferences.setDouble(_longitudeKey, location.longitude);
  }

  bool _isValidCoordinate(double latitude, double longitude) =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}
