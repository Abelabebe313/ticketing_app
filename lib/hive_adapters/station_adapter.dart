import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';

class StationInfoAdapter extends TypeAdapter<StationInfo> {
  @override
  final int typeId = 3; // Unique ID for this adapter

  @override
  StationInfo read(BinaryReader reader) {
    // Read data from binary and create a StationInfo object
    return StationInfo(
      id: reader.readString(),
      name: reader.readString(),
      location: reader.readString(),
      departure: reader.readString(),
      defaultLang: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, StationInfo obj) {
    // Write data from StationInfo object to binary
    writer.writeString(obj.id ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.name ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.location ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.departure ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.defaultLang ?? ''); // Use null-aware operator to handle null values
  }
}
