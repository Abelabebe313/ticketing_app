import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart'; // Import your StationInfo model here

Future<void> saveStationToHive() async {
  StationInfo station = StationInfo(
    id: "6",
    name: "Gindhiir",
    location: "Gindhiir",
    departure: "Gindhiir",
  );
  try {
    // Open Hive box for station
    final box = await Hive.openBox<StationInfo>('station');

    // Clear existing data
    await box.clear();

    // Put the station into the box
    await box.put('station', station);

    print('Station saved to Hive successfully');
  } catch (e) {
    print('Error saving station to Hive: $e');
  }
}
