import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/bloc/registration%20bloc/register_event.dart';
import 'package:transport_app/bloc/registration%20bloc/register_state.dart';
import 'package:transport_app/bloc/station%20bloc/station_event.dart';
import 'package:transport_app/bloc/station%20bloc/station_state.dart';
import 'package:transport_app/models/update_model.dart';
import 'package:transport_app/models/user.dart';
import 'package:transport_app/services/registrationService.dart';

class StationBloc extends Bloc<FetchStationInfoEvent, StationInfoState> {
  StationBloc(StationInfoState initialState)
      : super(StationInfoInitial()) {
    final userService = UserRegistration();

    on<FetchStationInfoEvent>((event, emit) async {
      emit(StationInfoLoading());
      try {
        final response = await userService.fetchStationInfo();
        emit(StationInfoSuccess(response));
      } catch (e) {
        emit(const StationInfoError('Error fetching station information'));
      }
    });
  }
}
