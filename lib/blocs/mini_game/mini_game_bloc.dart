import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'mini_game_event.dart';
part 'mini_game_state.dart';

class MiniGameBloc extends Bloc<MiniGameEvent, MiniGameState> {
  MiniGameBloc() : super(MiniGameState.initial()) {
    on<DecreaseHealthEvent>((event, emit) {
      final newHelth = state.archerHealth - 20;
      emit(state.copyWith(archerHealth: newHelth <= 0 ? 0 : newHelth));
      emit(state.copyWith(isArcherDead: state.archerHealth <= 0 ));
    });
    on<IncreaseHealthEvent>((event, emit) {
      final newHelth = state.archerHealth + 10;
      emit(state.copyWith(archerHealth: newHelth >= 100 ? 100 : newHelth));
    });
    on<ResetHealthEvent>((event, emit) {
      emit(state.copyWith(archerHealth: MiniGameState.initial().archerHealth));
      emit(state.copyWith(isArcherDead: state.archerHealth <= 0));
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
      final newGoblinSpawnPeriod = state.enemySpawnPeriod - 0.6;
      emit(state.copyWith(difficultyLevel: newDifficulty > 3 ? 1 : newDifficulty));
      emit(state.copyWith(enemySpawnPeriod: newDifficulty > 3 ? MiniGameState.initial().enemySpawnPeriod : newGoblinSpawnPeriod));
    });
    on<SpacePressingEvent>((event, emit) {
      emit(state.copyWith(isSpaceKeyPressing: true));
    });
    on<NotSpacePressingEvent>((event, emit) {
      emit(state.copyWith(isSpaceKeyPressing: false));
    });
    on<GoToMainPage>((event, emit) {
      emit(state.copyWith(flutterPage: 0));
    });
    on<GoToGamePage>((event, emit) {
      emit(state.copyWith(flutterPage: 1));
    });
    on<GoToPausePage>((event, emit) {
      emit(state.copyWith(flutterPage: 2));
    });
    on<GoToWinOrLosePage>((event, emit) {
      emit(state.copyWith(flutterPage: 3));
    });
    on<NextGameStageEvent>((event, emit) {
      emit(state.copyWith(gameStage: state.gameStage + 1));
    });
    on<ResetGameStageEvent>((event, emit) {
      emit(state.copyWith(gameStage: 1));
    });
    on<ChangeGameMode>((event, emit) {
      final newGameMode = state.gameMode + 1;
      emit(state.copyWith(gameMode: newGameMode > 1 ? 0 : newGameMode));
    });
    on<ResetAllGameEvent>((event, emit) {
      emit(state.copyWith(archerHealth: MiniGameState.initial().archerHealth));
      emit(state.copyWith(isArcherDead: state.archerHealth <= 0));
      emit(state.copyWith(monsterKillNumber: 0));
      emit(state.copyWith(flutterPage: 0));
      emit(state.copyWith(gameStage: 1));
      emit(state.copyWith(isTheGameReset: true));
    });
    on<NotResetAllGameEvent>((event, emit) {
      emit(state.copyWith(isTheGameReset: false));
    });
  } 
}