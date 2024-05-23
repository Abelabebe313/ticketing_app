import 'package:hive/hive.dart';

Future<void> clearAuthToken() async {
  try {
    // Open the Hive box
    final box = await Hive.openBox<String>('token');

    // Clear all data from the box
    await box.clear();
    print('Data cleared from token box successfully');
  } catch (e) {
    print('Error clearing data from token box: $e');
  } finally {
    // Close the Hive box
    await Hive.close();
  }
}
