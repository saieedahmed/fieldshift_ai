import '../models/farm_data.dart';
import '../models/farm_location.dart';

class MockFarmData {
  static const FarmData farm = FarmData(
    name: 'Green Valley Farm',
    location: FarmLocation(
      countryCode: 'EG',
      countryName: 'Egypt',
      localizedCountryName: 'مصر',
      placeName: 'El Meselha, Menoufia',
      localizedPlaceName: 'المصيلحة، المنوفية',
      latitude: 30.58,
      longitude: 30.96,
    ),
    areaHectares: 12.4,
    cropNameKey: 'wheat',
    temperatureC: 34,
    temperatureHistory: [28, 29, 31, 30, 32, 33, 34],
    humidityPercent: 46,
    rainProbability: 12,
    waterUseCubicMeters: 86,
    irrigationTime: 'Tomorrow · 6:00 AM',
    zones: [
      FarmZone(
        nameKey: 'zoneNorth',
        moisturePercent: 42,
        ndvi: 0.78,
        healthPercent: 91,
        cropNameKey: 'cropWheat',
      ),
      FarmZone(
        nameKey: 'zoneOrchard',
        moisturePercent: 38,
        ndvi: 0.71,
        healthPercent: 86,
        cropNameKey: 'cropCitrus',
      ),
      FarmZone(
        nameKey: 'zoneSouth',
        moisturePercent: 31,
        ndvi: 0.62,
        healthPercent: 74,
        cropNameKey: 'cropWheat',
      ),
    ],
  );
}
