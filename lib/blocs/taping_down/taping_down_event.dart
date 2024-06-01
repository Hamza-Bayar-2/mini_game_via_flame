part of 'taping_down_bloc.dart';

abstract class TapingDownEvent extends Equatable {
  const TapingDownEvent();

  @override
  List<Object> get props => [];
}

class TapingEvent extends TapingDownEvent {}

class NotTapingEvent extends TapingDownEvent {}

class DecreaseHealthEvent extends TapingDownEvent {}

class ResetHealthEvent extends TapingDownEvent {}

class FaceRightEvent extends TapingDownEvent {}

class FaceLeftEvent extends TapingDownEvent {}
