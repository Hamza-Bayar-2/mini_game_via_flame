part of 'mini_game_bloc.dart';

class MiniGameState extends Equatable {
  final bool isTapingDown;
  final int archerHelth;
  final bool isPlayerFacingRight;
  final bool isArcherDead;
  final bool isGameGoingOn;
  final int monsterKillNumber;
  final int difficultyLevel;
  final double goblinSpawnPeriod;
  final bool isSpaceKeyPressing;

  const MiniGameState({required this.isTapingDown, required this.archerHelth, required this.isPlayerFacingRight, required this.isArcherDead, required this.isGameGoingOn, required this.monsterKillNumber, required this.difficultyLevel, required this.goblinSpawnPeriod, required this.isSpaceKeyPressing});
  
  factory MiniGameState.initial() => const MiniGameState(isTapingDown: false, archerHelth: 100, isPlayerFacingRight: true, isArcherDead: false, isGameGoingOn: true, monsterKillNumber: 0, difficultyLevel: 1, goblinSpawnPeriod: 2, isSpaceKeyPressing: false);

  MiniGameState copyWith({bool? isTapingDown, int? archerHelth, bool? isPlayerFacingRight, bool? isArcherDead, bool? isGameGoingOn, int? monsterKillNumber, int? difficultyLevel, double? goblinSpawnPeriod, bool? isSpaceKeyPressing}){
    return MiniGameState(
      isTapingDown: isTapingDown ?? this.isTapingDown,
      archerHelth: archerHelth ?? this.archerHelth,
      isPlayerFacingRight: isPlayerFacingRight ?? this.isPlayerFacingRight,
      isArcherDead: isArcherDead ?? this.isArcherDead,
      isGameGoingOn: isGameGoingOn ?? this.isGameGoingOn,
      monsterKillNumber: monsterKillNumber ?? this.monsterKillNumber,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      goblinSpawnPeriod: goblinSpawnPeriod ?? this.goblinSpawnPeriod,
      isSpaceKeyPressing: isSpaceKeyPressing ?? this.isSpaceKeyPressing
    );
  }

  @override
  List<Object> get props => [isTapingDown, archerHelth, isPlayerFacingRight, isArcherDead, isGameGoingOn, monsterKillNumber, difficultyLevel, goblinSpawnPeriod, isSpaceKeyPressing];

  @override
  bool get stringify => true;
}