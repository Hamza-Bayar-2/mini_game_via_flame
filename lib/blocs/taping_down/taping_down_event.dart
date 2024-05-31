part of 'taping_down_bloc.dart';

abstract class TapingDownEvent extends Equatable {
  const TapingDownEvent();

  @override
  List<Object> get props => [];
}

class TapingDown extends TapingDownEvent {}

class NotTapingDown extends TapingDownEvent {}
