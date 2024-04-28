import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/bloc/registration%20bloc/register_event.dart';
import 'package:transport_app/bloc/registration%20bloc/register_state.dart';
import 'package:transport_app/models/update_model.dart';
import 'package:transport_app/models/user.dart';
import 'package:transport_app/services/registrationService.dart';

class StationBloc extends Bloc<FetchStationInfoEvent, RegisterState> {
  StationBloc(RegisterState initialState)
      : super(RegisterUserInitial()) {
    final userService = UserRegistration();

    on<FetchStationInfoEvent>((event, emit) async {
      emit(RegisterUserLoading());
      try {
        final response = await userService.fetchStationInfo();
        emit(LoadedStationState(response));
      } catch (e) {
        emit(const RegisterUserError('Error fetching station information'));
      }
    });
  }
}
