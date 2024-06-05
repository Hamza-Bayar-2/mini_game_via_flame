part of 'mini_game_bloc.dart';

class MiniGameState extends Equatable {
  final bool isTapingDown;
  final int archerHelth;
  final bool isPlayerFacingRight;
  final bool isArcherDead;
  final bool isGameGoingOn;
  final int monsterKillNumber;
  // there are 3 level of difficulty
  final int difficultyLevel;
  final double enemySpawnPeriod;
  final bool isSpaceKeyPressing;
  // 0 => main page
  // 1 => game page
  // 2 => pause page
  // 3 => win or lose page
  final int flutterPage;
  // there are 4 game stages (1 => goblin, 2 => mushroom, 3 => flying eye, 4 => skeleton)
  final int gameStage;
  // there are 2 game mode (0 => finite mode, 1 => kill mode)
  final int gameMode;

  const MiniGameState({required this.isTapingDown, required this.archerHelth, required this.isPlayerFacingRight, required this.isArcherDead, required this.isGameGoingOn, required this.monsterKillNumber, required this.difficultyLevel, required this.enemySpawnPeriod, required this.isSpaceKeyPressing, required this.flutterPage, required this.gameStage, required this.gameMode});
  
  factory MiniGameState.initial() => const MiniGameState(isTapingDown: false, archerHelth: 100, isPlayerFacingRight: true, isArcherDead: false, isGameGoingOn: true, monsterKillNumber: 0, difficultyLevel: 1, enemySpawnPeriod: 2, isSpaceKeyPressing: false, flutterPage: 0, gameStage: 1, gameMode: 0);

  MiniGameState copyWith({bool? isTapingDown, int? archerHelth, bool? isPlayerFacingRight, bool? isArcherDead, bool? isGameGoingOn, int? monsterKillNumber, int? difficultyLevel, double? enemySpawnPeriod, bool? isSpaceKeyPressing, int? flutterPage, int? gameStage, int? gameMode}){
    return MiniGameState(
      isTapingDown: isTapingDown ?? this.isTapingDown,
      archerHelth: archerHelth ?? this.archerHelth,
      isPlayerFacingRight: isPlayerFacingRight ?? this.isPlayerFacingRight,
      isArcherDead: isArcherDead ?? this.isArcherDead,
      isGameGoingOn: isGameGoingOn ?? this.isGameGoingOn,
      monsterKillNumber: monsterKillNumber ?? this.monsterKillNumber,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      enemySpawnPeriod: enemySpawnPeriod ?? this.enemySpawnPeriod,
      isSpaceKeyPressing: isSpaceKeyPressing ?? this.isSpaceKeyPressing,
      flutterPage: flutterPage ?? this.flutterPage,
      gameStage: gameStage ?? this.gameStage,
      gameMode: gameMode ?? this.gameMode
    );
  }

  @override
  List<Object> get props => [isTapingDown, archerHelth, isPlayerFacingRight, isArcherDead, isGameGoingOn, monsterKillNumber, difficultyLevel, enemySpawnPeriod, isSpaceKeyPressing, flutterPage, gameStage, gameMode];

  @override
  bool get stringify => true;
}