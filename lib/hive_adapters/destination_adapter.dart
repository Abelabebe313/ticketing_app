import 'package:hive/hive.dart';
import 'package:transport_app/models/update_model.dart';

class DestinationListAdapter extends TypeAdapter<DestinationList> {
  @override
  final int typeId = 1; // Unique ID for this adapter

  @override
  DestinationList read(BinaryReader reader) {
    // Read data from binary and create a DestinationList object
    return DestinationList(
      id: reader.readString(),
      stationId: reader.readString(),
      destination: reader.readString(),
      distance: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, DestinationList obj) {
    // Write data from DestinationList object to binary
    writer.writeString(obj.id ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.stationId ?? '');// Use null-aware operator to handle null values
    writer.writeString(obj.destination ?? ''); // Use null-aware operator to handle null values
    writer.writeString(obj.distance ?? ''); // Use null-aware operator to handle null values
  }
}
