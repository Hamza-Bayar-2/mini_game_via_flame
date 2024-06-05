
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:flutter/src/widgets/focus_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';
import 'package:mini_game_via_flame/sprites/flyingEye.dart';
import 'dart:async';
import 'package:mini_game_via_flame/sprites/goblin.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:mini_game_via_flame/sprites/heart.dart';
import 'package:mini_game_via_flame/sprites/mushroom.dart';
import 'package:mini_game_via_flame/sprites/skeleton.dart';

class MiniGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks, HasCollisionDetection{
  final MiniGameBloc miniGameBloc;
  MiniGame({required this.miniGameBloc});
  late final Sprite background;
  late final ArcherPlayer archerPlayer;
  // 0.72 seconds is the frame amount of the attack animation multiplies by step time (6 * 0.12)
  // The purpose of this timer is to ensure that arrows are released at the right time 
  // in the archer's attack animation. 
  final Timer countdownAndRepeat = Timer(0.72);
  late Bgm backgroundMusic = FlameAudio.bgmFactory(audioCache: FlameAudio.audioCache); 
  final double heartSpawnPeriod = 8;
  late SpawnComponent heartSpawner;
  late SpawnComponent enemySpawner1;
  late SpawnComponent enemySpawner2;
  late bool wasArcherDead = miniGameBloc.state.isArcherDead;
  late int previousDifficultyLevel = miniGameBloc.state.difficultyLevel;
  
  

  @override
  Future<void> onLoad() async{
    await FlameAudio.audioCache.loadAll(['running.mp3', 'arrow.mp3', 'death.mp3', 'hurt.mp3', 'monsterDeath.mp3', 'bgm.mp3', 'powerUp.mp3', 'win.mp3', 'lose.mp3']);
    await images.loadAllImages();
    background = Sprite(images.fromCache("background.png"));
    archerPlayer = ArcherPlayer();
    add(SpriteComponent(sprite: background, size: size));
    add(FlameBlocProvider.value(value: miniGameBloc, children: [archerPlayer]));

    heartSpawner = _heartCreater();
    enemySpawner1 = _enemyCreater(true, Vector2.all(280), size.x);
    enemySpawner2 = _enemyCreater(false, Vector2.all(280), 0);
    
    addAll({heartSpawner, enemySpawner1, enemySpawner2});
    return super.onLoad();
  }

  @override
  Future<void> update(double dt) async {
    
    if(miniGameBloc.state.flutterPage == 0 || miniGameBloc.state.flutterPage == 2) {
      // 0 => main page - 2 => pause page
      pauseEngine();
    } else if (miniGameBloc.state.flutterPage == 3) { 
      // 3 => win or lose page
      pauseEngine();
    }

    _arrowManager(dt);
    _gameStageManager();
    _backgroundMusicManager();
    _removeComponentWhenArcherDeadAndAddComponentWhenArcherRevive();
    _enemySpawnPeriodChanger();
    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if(keysPressed.contains(LogicalKeyboardKey.space)) {
      miniGameBloc.add(SpacePressingEvent());
      if(!miniGameBloc.state.isArcherDead && miniGameBloc.state.flutterPage != 3) {
        miniGameBloc.add(GoToGamePage());
        resumeEngine();
      }
    } else {
      miniGameBloc.add(NotSpacePressingEvent());
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // by this event the isTapingDown bool variable is changing to true
    miniGameBloc.add(TapingEvent());
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print("tapup");
    miniGameBloc.add(NotTapingEvent());
    super.onTapUp(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    print("tapDrag");
    miniGameBloc.add(TapingEvent());
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    print("tapDragEnd");
    miniGameBloc.add(NotTapingEvent());
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    print("tapDragCancel");
    miniGameBloc.add(NotTapingEvent());
    super.onDragCancel(event);
  }

  void _arrowManager(double dt) {
    if((miniGameBloc.state.isSpaceKeyPressing || miniGameBloc.state.isTapingDown) && !miniGameBloc.state.isArcherDead) {
      countdownAndRepeat.update(dt);
      countdownAndRepeat.resume();
      // when the time is up the arrow is released
      if(countdownAndRepeat.finished) {
        add(_arrowCreater());
        FlameAudio.play("arrow.mp3");
        countdownAndRepeat.start();
      }
    } else {
      countdownAndRepeat.stop();
    } 
  }

  // this method creates arrow everytime it called
  Arrow _arrowCreater() {
      return Arrow(
        position: archerPlayer.position + (miniGameBloc.state.isPlayerFacingRight ? Vector2(-80, -18) : Vector2(80, -18)),
        size: Vector2(48, 10),
        animation: _arrowAnimation(),
        anchor: Anchor.center
      );
    }

  SpriteAnimation _arrowAnimation() {
    return SpriteAnimation.fromFrameData(
      images.fromCache("Archer/Arrow/Move.png"),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.07,
        textureSize: Vector2(24, 5),
      ),
    );
  }

  SpawnComponent _enemyCreater(bool isSpawnRight, Vector2 enemySize, double positionX) {
    return SpawnComponent(
        factory: (index) {
          return _enemyPickerForEnemyCreaterMethod(isSpawnRight, enemySize);
        },
        period: miniGameBloc.state.enemySpawnPeriod,
        area: Rectangle.fromLTWH(positionX, 0, 0, size.y),
    );
  }

  dynamic _enemyPickerForEnemyCreaterMethod(bool isSpawnRight, Vector2 enemySize) {
    if(miniGameBloc.state.gameStage == 1) {
      return Goblin(isSpawnRight: isSpawnRight, size: enemySize);
    } else if(miniGameBloc.state.gameStage == 2) {
      return Mushroom(isSpawnRight: isSpawnRight, size: enemySize);
    } else if(miniGameBloc.state.gameStage == 3) {
      return FlyingEye(isSpawnRight: isSpawnRight, size: enemySize);
    } else if(miniGameBloc.state.gameStage == 4) {
      return Skeleton(isSpawnRight: isSpawnRight, size: enemySize);
    } 
    else {
      return Goblin(isSpawnRight: isSpawnRight, size: enemySize);
    }
  }

  SpawnComponent _heartCreater() {
    if(miniGameBloc.state.archerHelth < 100 && !miniGameBloc.state.isArcherDead){}
    return SpawnComponent(
      factory: (index) {
        return Heart(animation: _heartAnimation(), anchor: Anchor.center);
      },
      period: heartSpawnPeriod,
      area: Rectangle.fromLTWH(size.x / 12, size.y / 12, size.x * 0.8, size.y * 0.8),
    );
  }

  SpriteAnimation _heartAnimation() {
    return SpriteAnimation.fromFrameData(
      images.fromCache("heart.png"),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2.all(40),
      ),
    );
  }

  void _removeComponentWhenArcherDeadAndAddComponentWhenArcherRevive() {

    if(miniGameBloc.state.isArcherDead && !wasArcherDead){
      heartSpawner.removeFromParent();
      enemySpawner1.removeFromParent();
      enemySpawner2.removeFromParent();
    } else if (!miniGameBloc.state.isArcherDead && wasArcherDead){
      heartSpawner = _heartCreater();
      enemySpawner1 = _enemyCreater(true, Vector2.all(280), size.x);
      enemySpawner2 = _enemyCreater(false, Vector2.all(280), 0);

      addAll({heartSpawner, enemySpawner1, enemySpawner2});
    }

    wasArcherDead = miniGameBloc.state.isArcherDead;
  }

  void _enemySpawnPeriodChanger() {
    if(miniGameBloc.state.difficultyLevel != previousDifficultyLevel && !miniGameBloc.state.isArcherDead) {
      enemySpawner1.removeFromParent();
      enemySpawner2.removeFromParent();

      enemySpawner1 = _enemyCreater(true, Vector2.all(280), size.x,);
      enemySpawner2 = _enemyCreater(false, Vector2.all(280), 0);

      addAll({enemySpawner1, enemySpawner2});
    }

    previousDifficultyLevel = miniGameBloc.state.difficultyLevel;
  }

  void _backgroundMusicManager() {
    if(miniGameBloc.state.flutterPage != 1 || miniGameBloc.state.isArcherDead) {
      backgroundMusic.pause();
    } else if(!backgroundMusic.isPlaying) {
      backgroundMusic.play("bgm.mp3", volume: 0.2);
      backgroundMusic.resume();
    }
  }

  void _gameStageManager() {
    if(miniGameBloc.state.monsterKillNumber == 10 && miniGameBloc.state.gameStage == 1) {
      // game stage will be 2
      miniGameBloc.add(NextGameStageEvent());
      enemySpawner1.removeFromParent();
      enemySpawner2.removeFromParent();
      
      enemySpawner1 = _enemyCreater(true, Vector2.all(280), size.x,);
      enemySpawner2 = _enemyCreater(false, Vector2.all(280), 0);

      addAll({enemySpawner1, enemySpawner2});
    } else if(miniGameBloc.state.monsterKillNumber == 20 && miniGameBloc.state.gameStage == 2) {
      // game stage will be 3
      miniGameBloc.add(NextGameStageEvent());
      enemySpawner1.removeFromParent();
      enemySpawner2.removeFromParent();
      
      enemySpawner1 = _enemyCreater(true, Vector2.all(280), size.x,);
      enemySpawner2 = _enemyCreater(false, Vector2.all(280), 0);

      addAll({enemySpawner1, enemySpawner2});
    } else if(miniGameBloc.state.monsterKillNumber == 30 && miniGameBloc.state.gameStage == 3) {
      // game stage will be 4 (final stage)
      miniGameBloc.add(NextGameStageEvent());
      enemySpawner1.removeFromParent();
      enemySpawner2.removeFromParent();
      
      enemySpawner1 = _enemyCreater(true, Vector2.all(280), size.x,);
      enemySpawner2 = _enemyCreater(false, Vector2.all(280), 0);

      addAll({enemySpawner1, enemySpawner2});
    } else if(miniGameBloc.state.monsterKillNumber == 40 && miniGameBloc.state.gameStage == 4) {
      // game stage will be reset to 1 
      miniGameBloc.add(ResetGameStageEvent());
      enemySpawner1.removeFromParent();
      enemySpawner2.removeFromParent();

      // I add the spawnres again so when the player starts playing again the monsters continuo spawning
      enemySpawner1 = _enemyCreater(true, Vector2.all(280), size.x,);
      enemySpawner2 = _enemyCreater(false, Vector2.all(280), 0);

      addAll({enemySpawner1, enemySpawner2});
      
      // if the player plays gameMode 0 (finite mode) he will win the game
      // otherwise the player will continuo playing.
      if(miniGameBloc.state.gameMode == 0) {
        // The player completed all 4 stages and won the game flutterPage => 3
        FlameAudio.play("win.mp3", volume: 0.5);
        miniGameBloc.add(GoToWinOrLosePage());
      }
    }
  }
}