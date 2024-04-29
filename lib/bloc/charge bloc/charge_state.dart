import 'package:equatable/equatable.dart';


class ChargeState {}

class InitialState extends ChargeState {}

class UpdateState extends ChargeState {
  final double counter;
  UpdateState(this.counter);
}