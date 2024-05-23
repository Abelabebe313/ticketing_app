import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';

class TariffInfoAdapter extends TypeAdapter<TariffInfo> {
  @override
  final int typeId = 2; // Unique ID for this adapter

  @override
  TariffInfo read(BinaryReader reader) {
    try {
      // Read data from binary and create a TariffInfo object
      return TariffInfo(
        stationId: reader.readString(),
        destinationId: reader.readString(),
        tariff: reader.readString(),
        level_1: reader.readString(),
        level_2: reader.readString(),
        level_3: reader.readString(),
        is_lessthan_16: reader.readString(),
        level_1_mini: reader.readString(),
        level_2_mini: reader.readString(),
        level_3_mini: reader.readString(),
        updatedDate: reader.readString(),
      );
    } catch (e) {
      print('Error reading TariffInfo: $e');
      // Return a default TariffInfo object or null in case of error
      return TariffInfo();
    }
  }

  @override
  void write(BinaryWriter writer, TariffInfo obj) {
    try {
      // Write data from TariffInfo object to binary
      writer.writeString(obj.stationId ?? '');
      writer.writeString(obj.destinationId ?? '');
      writer.writeString(obj.tariff ?? '');
      writer.writeString(obj.level_1 ?? '');
      writer.writeString(obj.level_2 ?? '');
      writer.writeString(obj.level_3 ?? '');
      writer.writeString(obj.is_lessthan_16 ?? '');
      writer.writeString(obj.level_1_mini ?? '');
      writer.writeString(obj.level_2_mini ?? '');
      writer.writeString(obj.level_3_mini ?? '');
      writer.writeString(obj.updatedDate ?? '');
    } catch (e) {
      print('Error writing TariffInfo: $e');
    }
  }
}
