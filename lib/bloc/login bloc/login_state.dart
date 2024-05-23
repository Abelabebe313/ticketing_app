import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends UserState {}

class LoginLoading extends UserState {}

// class UserLoaded extends UserState {}

class LoginError extends UserState {
  final String errorMessage;

  const LoginError(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}


class LoadedLoginState extends UserState {
  final String phoneNumber;
  final String password;

  const LoadedLoginState(this.phoneNumber, this.password);

  @override
  List<Object> get props => [phoneNumber, password];
}
