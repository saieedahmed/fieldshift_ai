import 'farm_location.dart';

class FarmData {
  const FarmData({
    required this.name,
    required this.location,
    required this.areaHectares,
    required this.cropNameKey,
    required this.temperatureC,
    required this.temperatureHistory,
    required this.humidityPercent,
    required this.rainProbability,
    required this.waterUseCubicMeters,
    required this.zones,
    required this.irrigationTime,
  });

  final String name;
  final FarmLocation location;
  final double areaHectares;
  final String cropNameKey;
  final double temperatureC;
  final List<double> temperatureHistory;
  final int humidityPercent;
  final int rainProbability;
  final int waterUseCubicMeters;
  final List<FarmZone> zones;
  final String irrigationTime;

  FarmData copyWith({FarmLocation? location}) => FarmData(
    name: name,
    location: location ?? this.location,
    areaHectares: areaHectares,
    cropNameKey: cropNameKey,
    temperatureC: temperatureC,
    temperatureHistory: temperatureHistory,
    humidityPercent: humidityPercent,
    rainProbability: rainProbability,
    waterUseCubicMeters: waterUseCubicMeters,
    zones: zones,
    irrigationTime: irrigationTime,
  );
}

class FarmZone {
  const FarmZone({
    required this.nameKey,
    required this.moisturePercent,
    required this.ndvi,
    required this.healthPercent,
    required this.cropNameKey,
  });

  final String nameKey;
  final int moisturePercent;
  final double ndvi;
  final int healthPercent;
  final String cropNameKey;
}
