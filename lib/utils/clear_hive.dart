import 'package:hive/hive.dart';

Future<void> clearAllHiveData() async {
  // Clear data from the 'destinations' box
  await clearBox('destinations');

  // Clear data from the 'tariffs' box
  await clearBox('tariffs');

  // Clear data from the 'vehicles' box
  await clearBox('vehicles');
}

Future<void> clearBox(String boxName) async {
  try {
    // Open the Hive box
    final box = await Hive.openBox(boxName);

    // Clear all data from the box
    await box.clear();
    print('Data cleared from $boxName box successfully');
  } catch (e) {
    print('Error clearing data from $boxName box: $e');
  }
}
