part of 'mini_game_bloc.dart';

abstract class MiniGameEvent extends Equatable {
  const MiniGameEvent();

  @override
  List<Object> get props => [];
}

class TapingEvent extends MiniGameEvent {}

class NotTapingEvent extends MiniGameEvent {}

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
