part of 'taping_down_bloc.dart';

class TapingDownState extends Equatable {
  final bool isTapingDown;
  final int archerHelth;
  final bool isPlayerFacingRight;
  const TapingDownState({required this.isTapingDown, required this.archerHelth, required this.isPlayerFacingRight});
  
  factory TapingDownState.initial() => const TapingDownState(isTapingDown: false, archerHelth: 100, isPlayerFacingRight: true);

  TapingDownState copyWith({bool? isTapingDown, int? archerHelth, bool? isPlayerFacingRight}){
    return TapingDownState(
      isTapingDown: isTapingDown ?? this.isTapingDown,
      archerHelth: archerHelth ?? this.archerHelth,
      isPlayerFacingRight: isPlayerFacingRight ?? this.isPlayerFacingRight
    );
  }

  @override
  List<Object> get props => [isTapingDown, archerHelth, isPlayerFacingRight];

  @override
  bool get stringify => true;
}