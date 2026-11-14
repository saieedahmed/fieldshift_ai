import '../mock/mock_farm_data.dart';
import '../models/farm_data.dart';

abstract interface class FarmRepository {
  FarmData getFarm();
}

class DemoFarmRepository implements FarmRepository {
  @override
  FarmData getFarm() => MockFarmData.farm;
}
