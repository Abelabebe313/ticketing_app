import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';

class TariffInfoAdapter extends TypeAdapter<TariffInfo> {
  @override
  final int typeId = 2; // Unique ID for this adapter

  @override
  TariffInfo read(BinaryReader reader) {
    // Read data from binary and create a TariffInfo object
    return TariffInfo(
      stationId: reader.readString(),
      destinationId: reader.readString(),
      tariff: reader.readString(),
      updatedDate: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TariffInfo obj) {
    // Write data from TariffInfo object to binary
    writer.writeString(obj.stationId ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.destinationId ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.tariff ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.updatedDate ?? ''); // Use null-aware operator to handle null values
  }
}
