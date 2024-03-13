import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:transport_app/models/update_model.dart';

Future<void> saveTariffListToHive(List<TariffInfo> tariffList) async {
  try {
    // Open Hive box for tariffs
    final box = await Hive.openBox<TariffInfo>('tariffs');

    // Clear existing data and add new data
    await box.clear(); // Clear existing data
    await box.addAll(tariffList); // Add new tariff list

    print('Tariff list saved to Hive successfully');
  } catch (e) {
    print('Error saving tariff list to Hive: $e');
  }
}
