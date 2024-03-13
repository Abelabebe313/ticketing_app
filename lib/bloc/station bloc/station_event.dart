import 'package:equatable/equatable.dart';
import 'package:transport_app/models/update_model.dart';

abstract class StationInfoEvent extends Equatable {
  const StationInfoEvent();
}

class FetchStationInfoEvent extends StationInfoEvent {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
