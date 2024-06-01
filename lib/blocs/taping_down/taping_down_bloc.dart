import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'taping_down_event.dart';
part 'taping_down_state.dart';

class TapingDownBloc extends Bloc<TapingDownEvent, TapingDownState> {
  TapingDownBloc() : super(TapingDownState.initial()) {
    on<TapingEvent>((event, emit) {
      emit(state.copyWith(isTapingDown: true));
    });
    on<NotTapingEvent>((event, emit) {
      emit(state.copyWith(isTapingDown: false));
    });
    on<DecreaseHealthEvent>((event, emit) {
      final newHelth = state.archerHelth - 30;
      emit(state.copyWith(archerHelth: newHelth < 0 ? 0 : newHelth));
    });
    on<ResetHealthEvent>((event, emit) {
      emit(state.copyWith(archerHelth: TapingDownState.initial().archerHelth));
    });
    on<FaceRightEvent>((event, emit) {
      emit(state.copyWith(isPlayerFacingRight: true));
    });
    on<FaceLeftEvent>((event, emit) {
      emit(state.copyWith(isPlayerFacingRight: false));
    });
  }
}