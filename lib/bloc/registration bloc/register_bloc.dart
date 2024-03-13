import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/bloc/registration%20bloc/register_event.dart';
import 'package:transport_app/bloc/registration%20bloc/register_state.dart';
import 'package:transport_app/models/update_model.dart';
import 'package:transport_app/models/user.dart';
import 'package:transport_app/services/registrationService.dart';

class UserRgistrationBloc extends Bloc<RegisterEvent, RegisterState> {
  UserRgistrationBloc(RegisterState initialState)
      : super(RegisterUserInitial()) {
    final userService = UserRegistration();

    on<RegisterUserEvent>((event, emit) async {
      emit(RegisterUserLoading());
      try {
        final response = await userService.register(
          UserModel(
            name: event.name,
            phone: event.phone,
            password: event.password,
            password_confirmation: event.confirmPassword,
          ),
        );
        emit(LoadedRegisterUserState(
            event.name, event.phone, event.password, event.confirmPassword));
      } catch (e) {
        emit(const RegisterUserError('Error logging in'));
      }
    });

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
