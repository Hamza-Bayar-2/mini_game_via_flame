part of 'taping_down_bloc.dart';

class TapingDownState extends Equatable {
  final bool isTapingDown;
  const TapingDownState({required this.isTapingDown});
  
  factory TapingDownState.initial() => const TapingDownState(isTapingDown: false);

  TapingDownState copyWith({bool? isTapingDown}){
    return TapingDownState(isTapingDown: isTapingDown ?? this.isTapingDown);
  }

  @override
  List<Object> get props => [isTapingDown];

  @override
  bool get stringify => true;
}