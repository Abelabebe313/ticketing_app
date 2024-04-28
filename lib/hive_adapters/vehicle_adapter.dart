import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';

class VehicleListAdapter extends TypeAdapter<VehicleList> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  VehicleList read(BinaryReader reader) {
    // Read data from binary and create a VehicleList object
    return VehicleList(
      id: reader.readString(),
      stationId: reader.readString(),
      associationName: reader.readString(),
      level: reader.readString(),
      plateNo: reader.readString(),
      type: reader.readString(),
      capacity: reader.readString(),
      date: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, VehicleList obj) {
    // Write data from VehicleList object to binary
    writer.writeString(obj.id ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.stationId ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.associationName ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.level ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.plateNo ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.type ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.capacity ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.date ?? ''); // Use null-aware operator to handle null values
  }
}
