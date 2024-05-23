import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/bloc/login%20bloc/login_event.dart';
import 'package:transport_app/bloc/login%20bloc/login_state.dart';
import 'package:transport_app/services/loginService.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(UserState initialState) : super(LoginInitial()) {
    final userService = UserLogin();

    on<LoginUserEvent>((event, emit) async {
      emit(LoginLoading());
        print('========> inside try bloc');
      try {
        final response = await userService.login(event.phone, event.password);
        // print('response: $response');
        
        if (response) {
          emit(LoadedLoginState(event.phone, event.password));
        } else {
          emit(const LoginError('Error when logging in user'));
        }
      } catch (e) {
        print('Login error: $e');
        emit(const LoginError('Error LOGGING in'));
      }
    });
  }
}
