import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'mini_game_event.dart';
part 'mini_game_state.dart';

class MiniGameBloc extends Bloc<MiniGameEvent, MiniGameState> {
  MiniGameBloc() : super(MiniGameState.initial()) {
    on<TapingEvent>((event, emit) {
      emit(state.copyWith(isTapingDown: true));
    });
    on<NotTapingEvent>((event, emit) {
      emit(state.copyWith(isTapingDown: false));
    });
    on<DecreaseHealthEvent>((event, emit) {
      final newHelth = state.archerHelth - 10;
      emit(state.copyWith(archerHelth: newHelth <= 0 ? 0 : newHelth));
      emit(state.copyWith(isArcherDead: state.archerHelth <= 0 ));
    });
    on<IncreaseHealthEvent>((event, emit) {
      final newHelth = state.archerHelth + 20;
      emit(state.copyWith(archerHelth: newHelth >= 100 ? 100 : newHelth));
    });
    on<ResetHealthEvent>((event, emit) {
      emit(state.copyWith(archerHelth: MiniGameState.initial().archerHelth));
      emit(state.copyWith(isArcherDead: state.archerHelth <= 0));
      emit(state.copyWith(monsterKillNumber: 0));
    });
    on<FaceRightEvent>((event, emit) {
      emit(state.copyWith(isPlayerFacingRight: true));
    });
    on<FaceLeftEvent>((event, emit) {
      emit(state.copyWith(isPlayerFacingRight: false));
    });
    on<StopTheGame>((event, emit) {
      emit(state.copyWith(isGameGoingOn: false));
    });
    on<StartTheGame>((event, emit) {
      emit(state.copyWith(isGameGoingOn: true));
    });
    on<KillMonster>((event, emit) {
      emit(state.copyWith(monsterKillNumber: state.monsterKillNumber + 1));
    });
    on<ChangeDifficultyLevelEvent>((event, emit) {
      final newDifficulty = state.difficultyLevel + 1;
      final newGoblinSpawnPeriod = state.goblinSpawnPeriod - 0.7;
      emit(state.copyWith(difficultyLevel: newDifficulty > 3 ? 1 : newDifficulty));
      emit(state.copyWith(goblinSpawnPeriod: newDifficulty > 3 ? 2 : newGoblinSpawnPeriod));
    });
  }
}