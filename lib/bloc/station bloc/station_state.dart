import 'package:equatable/equatable.dart';
import 'package:transport_app/models/update_model.dart';

abstract class StationInfoState extends Equatable {
  const StationInfoState();

  @override
  List<Object> get props => [];
}

class StationInfoLoading extends StationInfoState {}

class StationInfoSuccess extends StationInfoState {
  final List<StationInfo> stations;

  const StationInfoSuccess(this.stations);

  @override
  List<Object> get props => [stations];
}

class StationInfoError extends StationInfoState {
  final String errorMessage;

  const StationInfoError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
