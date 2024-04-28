import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';

Future<void> saveVehicleListToHive(List<VehicleList> vehicleList) async {
  try {
    // Open Hive box for vehicles
    final box = await Hive.openBox<VehicleList>('vehicles');
    final busBox = await Hive.openBox<VehicleList>('bus_queue');

    // Clear existing data and add new data
    await box.clear(); // Clear existing data
    await box.addAll(vehicleList); // Add new vehicle list
    await busBox.clear();
    await busBox.addAll(vehicleList);

    print('Vehicle list saved to Hive successfully');
  } catch (e) {
    print('Error saving vehicle list to Hive: $e');
  }
}