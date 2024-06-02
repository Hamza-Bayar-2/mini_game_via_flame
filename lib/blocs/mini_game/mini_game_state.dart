part of 'mini_game_bloc.dart';

class MiniGameState extends Equatable {
  final bool isTapingDown;
  final int archerHelth;
  final bool isPlayerFacingRight;
  final bool isArcherDead;
  final bool isGameGoingOn;
  final int monsterKillNumber;
  const MiniGameState({required this.isTapingDown, required this.archerHelth, required this.isPlayerFacingRight, required this.isArcherDead, required this.isGameGoingOn, required this.monsterKillNumber});
  
  factory MiniGameState.initial() => const MiniGameState(isTapingDown: false, archerHelth: 100, isPlayerFacingRight: true, isArcherDead: false, isGameGoingOn: true, monsterKillNumber: 0);

  MiniGameState copyWith({bool? isTapingDown, int? archerHelth, bool? isPlayerFacingRight, bool? isArcherDead, bool? isGameGoingOn, int? monsterKillNumber}){
    return MiniGameState(
      isTapingDown: isTapingDown ?? this.isTapingDown,
      archerHelth: archerHelth ?? this.archerHelth,
      isPlayerFacingRight: isPlayerFacingRight ?? this.isPlayerFacingRight,
      isArcherDead: isArcherDead ?? this.isArcherDead,
      isGameGoingOn: isGameGoingOn ?? this.isGameGoingOn,
      monsterKillNumber: monsterKillNumber ?? this.monsterKillNumber
    );
  }

  @override
  List<Object> get props => [isTapingDown, archerHelth, isPlayerFacingRight, isArcherDead, isGameGoingOn, monsterKillNumber];

  @override
  bool get stringify => true;
}