class FarmLocation {
  const FarmLocation({
    required this.countryCode,
    required this.countryName,
    required this.localizedCountryName,
    required this.placeName,
    required this.localizedPlaceName,
    required this.latitude,
    required this.longitude,
  });

  final String countryCode;
  final String countryName;
  final String localizedCountryName;
  final String placeName;
  final String localizedPlaceName;
  final double latitude;
  final double longitude;

  String displayName({required bool isArabic}) {
    final country = isArabic ? localizedCountryName : countryName;
    final place = isArabic ? localizedPlaceName : placeName;
    return isArabic ? '$place، $country' : '$place, $country';
  }

  FarmLocation copyWith({
    String? countryCode,
    String? countryName,
    String? localizedCountryName,
    String? placeName,
    String? localizedPlaceName,
    double? latitude,
    double? longitude,
  }) {
    return FarmLocation(
      countryCode: countryCode ?? this.countryCode,
      countryName: countryName ?? this.countryName,
      localizedCountryName: localizedCountryName ?? this.localizedCountryName,
      placeName: placeName ?? this.placeName,
      localizedPlaceName: localizedPlaceName ?? this.localizedPlaceName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
