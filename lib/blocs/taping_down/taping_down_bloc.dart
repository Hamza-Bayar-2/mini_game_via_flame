import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'taping_down_event.dart';
part 'taping_down_state.dart';

class TapingDownBloc extends Bloc<TapingDownEvent, TapingDownState> {
  TapingDownBloc() : super(TapingDownState.initial()) {
    on<TapingDown>((event, emit) {
      emit(state.copyWith(isTapingDown: true));
    });
    on<NotTapingDown>((event, emit) {
      emit(state.copyWith(isTapingDown: false));
    });
  }
}
