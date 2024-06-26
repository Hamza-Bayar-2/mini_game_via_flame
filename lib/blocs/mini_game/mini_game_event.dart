part of 'mini_game_bloc.dart';

abstract class MiniGameEvent extends Equatable {
  const MiniGameEvent();

  @override
  List<Object> get props => [];
}

class DecreaseHealthEvent extends MiniGameEvent {}

class IncreaseHealthEvent extends MiniGameEvent {}

class ResetHealthEvent extends MiniGameEvent {}

class FaceRightEvent extends MiniGameEvent {}

class FaceLeftEvent extends MiniGameEvent {}

class StopTheGame extends MiniGameEvent {}

class StartTheGame extends MiniGameEvent {}

class KillMonster extends MiniGameEvent {}

class ChangeDifficultyLevelEvent extends MiniGameEvent {}

class SpacePressingEvent extends MiniGameEvent {}

class NotSpacePressingEvent extends MiniGameEvent {}

class GoToMainPage extends MiniGameEvent {}

class GoToGamePage extends MiniGameEvent {}

class GoToPausePage extends MiniGameEvent {}

class GoToWinOrLosePage extends MiniGameEvent {}

class NextGameStageEvent extends MiniGameEvent {}

class ResetGameStageEvent extends MiniGameEvent {}

class ChangeGameMode extends MiniGameEvent {}

class ResetAllGameEvent extends MiniGameEvent {}

class NotResetAllGameEvent extends MiniGameEvent {}