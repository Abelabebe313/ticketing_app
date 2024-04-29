import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transport_app/bloc/charge%20bloc/charge_state.dart';

import 'charge_event.dart';

class ChargeBloc extends Bloc<ChargeEvents, ChargeState> {
  double counter = 0.0;
  ChargeBloc(): super(InitialState()){
    on<NumberIncreaseEvent>(onNumberIncrease);
    on<ClearEvent>(onClear);
  }
  void onNumberIncrease(
      NumberIncreaseEvent event, Emitter<ChargeState> emit) async {
    counter = counter + 1;
    emit(UpdateState(counter));
  }

  void onClear(
      ClearEvent event, Emitter<ChargeState> emit) async {
    counter = counter - 1;
    emit(UpdateState(counter));
  }
}