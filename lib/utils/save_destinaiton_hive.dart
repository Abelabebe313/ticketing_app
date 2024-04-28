import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:transport_app/models/update_model.dart';

Future<void> saveDestinationListToHive(List<DestinationList> destinationList) async {
  try {
    // Open Hive box for destinations
    final box = await Hive.openBox<DestinationList>('destinations');

    // Clear existing data and add new data
    await box.clear(); // Clear existing data
    await box.addAll(destinationList); // Add new destination list

    print('Destination list saved to Hive successfully');
  } catch (e) {
    print('Error saving destination list to Hive: $e');
  }
}
