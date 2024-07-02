import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:flutter/src/widgets/focus_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/pattern%20implementation/enemy.dart';
import 'package:mini_game_via_flame/pattern%20implementation/state_pattern/enemy_walking_state.dart';
import 'package:mini_game_via_flame/pattern%20implementation/strategy_pattern/enemy_direction_left_strategy.dart';
import 'package:mini_game_via_flame/pattern%20implementation/strategy_pattern/enemy_direction_right_strategy.dart';
import 'package:mini_game_via_flame/pools/arrow_pool.dart';
import 'package:mini_game_via_flame/pools/enemy_pool.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';
import 'dart:async';
import 'package:mini_game_via_flame/sprites/goblin.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:mini_game_via_flame/sprites/heart.dart';

import '../pools/new_enemy_pool.dart';

class MiniGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks, HasCollisionDetection, HasDecorator{
  final MiniGameBloc miniGameBloc;
  MiniGame({required this.miniGameBloc});
  
  late final SpriteComponent background;
  late final ArcherPlayer archerPlayer;
  // 0.72 seconds is the frame amount of the attack animation multiplies by step time (6 * 0.12)
  // The purpose of this timer is to ensure that arrows are released at the right time 
  // in the archer's attack animation. 
  final Timer arrowTimer = Timer(0.51);
  late Bgm backgroundMusic = FlameAudio.bgmFactory(audioCache: FlameAudio.audioCache); 
  final double heartSpawnPeriod = 7.5;
  late SpawnComponent heartSpawner;
  late SpawnComponent enemySpawner1;
  late SpawnComponent enemySpawner2;
  late int previousDifficultyLevel = miniGameBloc.state.difficultyLevel;
  late int previousMonsterKillNumber = miniGameBloc.state.monsterKillNumber;
  late int previousArcherHealth = miniGameBloc.state.archerHealth;
  late final CameraComponent cameraComponent;
  @override
  late final World world;
  final archerScale = 0.3;
  final monstersScale = 0.44;
  final arrowScale = 0.35;
  final heartScale = 0.05;
  late final ArrowPool arrowPool;
  late final EnemyPool enemyPool;
  late final NewEnemyPool newEnemyPool;
  late Arrow arrow;
  int streakKill = 0;
  late Enemy swordMan;


  @override
  Future<void> onLoad() async{
    await FlameAudio.audioCache.loadAll(['running.mp3', 'arrow.mp3', 'death.mp3', 'hurt.mp3', 'monsterDeath.mp3', 'bgm.mp3', 'powerUp.mp3', 'win.mp3', 'lose.mp3', 'skeletonDeath.mp3', 'skeletonDeath2.mp3', 'mushroomDeath.mp3', 'flyingEyeDeath.mp3', 'shield.mp3']);
    await images.loadAllImages();
    background = SpriteComponent(sprite: Sprite(images.fromCache("gameBackground.png")), size: size);
    archerPlayer = ArcherPlayer(size: Vector2.all(background.size.y * archerScale), position: Vector2(background.size.x / 2, background.size.y / 2));
    heartSpawner = _heartSpawner();
    enemySpawner1 = _enemySpawner(true, Vector2.all(background.size.y * monstersScale));
    enemySpawner2 = _enemySpawner(false, Vector2.all(background.size.y * monstersScale));
    arrowPool = ArrowPool();
    enemyPool = EnemyPool();
    newEnemyPool = NewEnemyPool();

    world = World(children: [background, archerPlayer, heartSpawner, enemySpawner1, enemySpawner2, arrowPool, enemyPool]);
    await add(world); 
    cameraComponent = CameraComponent.withFixedResolution(
      width: size.x,
      height: size.y,
      world: world
    );
    await add(cameraComponent);
    // cameraComponent.follow(archerPlayer);
    cameraComponent.moveTo(size / 2);

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

    _difficultyLevelChange();
    _resetAllGame();
    _arrowManager(dt);
    _gameStageManager();
    _backgroundMusicManager();
    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // this is used to throw arrows
    // also space key is used to continuo the game if it was paused
    if(keysPressed.contains(LogicalKeyboardKey.space)) {
      miniGameBloc.add(SpacePressingEvent());
      if(!miniGameBloc.state.isArcherDead && miniGameBloc.state.flutterPage != 3) {
        miniGameBloc.add(GoToGamePage());
        resumeEngine();
      }
    } else {
      miniGameBloc.add(NotSpacePressingEvent());
    }

    if(keysPressed.contains(LogicalKeyboardKey.escape) && miniGameBloc.state.flutterPage != 3){
      miniGameBloc.add(GoToPausePage());
    }
    return super.onKeyEvent(event, keysPressed);
  }

  Future<void> _arrowManager(double dt) async {
    if((miniGameBloc.state.isSpaceKeyPressing) && !miniGameBloc.state.isArcherDead) {
      arrowTimer.update(dt);
      arrowTimer.resume();
      // when the time is up the arrow will be throwen
      if(arrowTimer.finished) {
        arrow = arrowPool.acquire();
        // the retun arrow could be a new arrow
        // so first we check if the world has this arrow, if not we add it to the world
        if(!world.children.contains(arrow)) {
          await world.add(arrow);
        }
        // after the arrow is ready it will be fired
        arrow.fire();
        FlameAudio.play("arrow.mp3");
        arrowTimer.start();
        // from here we can check how many arrow dose the pool has
        print("arrow pool: ${arrowPool.getArrowPool.length}");
      }
    } else {
      arrowTimer.stop();
    } 
  }

  SpawnComponent _enemySpawner(bool isSpawnRight, Vector2 enemySize) {
    return SpawnComponent(
        factory: (index) {
          return _enemyPickerForEnemyCreaterMethod(isSpawnRight, enemySize)..debugMode = false;
        },
        period: miniGameBloc.state.enemySpawnPeriod,
        area: Rectangle.fromLTWH(isSpawnRight ? background.size.x : 0, background.size.y * 0.3, 0, background.size.y * 0.6),
    );
  }

  dynamic _enemyPickerForEnemyCreaterMethod(bool isSpawnRight, Vector2 enemySize) {
    if(miniGameBloc.state.gameStage == 1) {
      // print("goblin pool: ${enemyPool.getGoblinPool.length}");
      // final goblin = enemyPool.goblinAcquire(isSpawnRight, enemySize);
      // goblin.activate();
      // return goblin;
      final swordMan = newEnemyPool.swordManAcquire(isSpawnRight);
      return swordMan;
    } else if(miniGameBloc.state.gameStage == 2) {
      print("mushroom pool: ${enemyPool.getMushroomPool.length}");
      final mushroom = enemyPool.mushroomAcquire(isSpawnRight, enemySize);
      mushroom.activate();
      return mushroom;
    } else if(miniGameBloc.state.gameStage == 3) {
      print("flying Eye pool: ${enemyPool.getFlyingEyePool.length}");
      final flyingEye = enemyPool.flyingEyeAcquire(isSpawnRight, enemySize);
      flyingEye.activate();
      return flyingEye;
    } else if(miniGameBloc.state.gameStage == 4) {
      print("skeleton pool: ${enemyPool.getSkeletonPool.length}");
      final skeleton = enemyPool.skeletonAcquire(isSpawnRight, enemySize);
      skeleton.activate();
      return skeleton;
    } 
    else {
      return Goblin(isSpawnRight: isSpawnRight, enemySize: enemySize);
    }
  }

  SpawnComponent _heartSpawner() {
    return SpawnComponent(
      factory: (index) {
        return Heart(animation: _heartAnimation(), anchor: Anchor.center, size: Vector2.all(background.size.y * heartScale));
      },
      period: heartSpawnPeriod,
      area: Rectangle.fromLTWH(background.size.x / 12, background.size.y / 3, background.size.x * 0.8, background.size.y * 0.6),
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

  void _backgroundMusicManager() {
    if(miniGameBloc.state.flutterPage != 1 || miniGameBloc.state.isArcherDead) {
      backgroundMusic.pause();
    } else if(!backgroundMusic.isPlaying) {
      backgroundMusic.play("bgm.mp3", volume: 0.2);
      backgroundMusic.resume();
    }
  }

  void _gameStageManager() {
    if(miniGameBloc.state.monsterKillNumber % 40 == 10 && miniGameBloc.state.gameStage == 1) {
      // game stage will be 2
      miniGameBloc.add(NextGameStageEvent());
    } else if(miniGameBloc.state.monsterKillNumber % 40 == 20 && miniGameBloc.state.gameStage == 2) {
      // game stage will be 3
      miniGameBloc.add(NextGameStageEvent());
    } else if(miniGameBloc.state.monsterKillNumber % 40 == 30 && miniGameBloc.state.gameStage == 3) {
      // game stage will be 4 (final stage)
      miniGameBloc.add(NextGameStageEvent());
    } else if(miniGameBloc.state.monsterKillNumber % 40 == 0 && miniGameBloc.state.gameStage == 4) {
      // game stage will be reset to 1 
      miniGameBloc.add(ResetGameStageEvent());
      
      // if the player plays gameMode 0 (finite mode) the game will has a win case
      // otherwise the player will continuo playing.
      if(miniGameBloc.state.gameMode == 0) {
        // The player completed all 4 stages and won the game flutterPage => 3
        FlameAudio.play("win.mp3", volume: 0.5);
        miniGameBloc.add(GoToWinOrLosePage());
      }
    }
  }

  // the spawner is removed and added again because
  // when the player moves to the next stage 
  // the new spawner with the new monster will be added 
  // and the previous one will be removed
  // this also used when the game difficulty changes
  void _removeAndAddEnemySpawner() {
    enemySpawner1.removeFromParent();
    enemySpawner2.removeFromParent();

    enemySpawner1 = _enemySpawner(true, Vector2.all(background.size.y * monstersScale));
    enemySpawner2 = _enemySpawner(false, Vector2.all(background.size.y * monstersScale));

    world.addAll({enemySpawner1, enemySpawner2}); 
  }

  // this method will be used when the difficulty changes
  void _difficultyLevelChange() {
    if(miniGameBloc.state.difficultyLevel != previousDifficultyLevel) {
      _removeAndAddEnemySpawner();
    }
    previousDifficultyLevel = miniGameBloc.state.difficultyLevel;
  }

  void _resetAllGame() {
    // this works when the player press exit on the pause page
    if(miniGameBloc.state.isTheGameReset){
      // this makes the isTheGamereset => false
      miniGameBloc.add(NotResetAllGameEvent());
    }
  }

  // by using gameRef I added the blood prarticle to the monsters
  ParticleSystemComponent bloodParticlesForMonsters(Vector2 position) {
    final Random random = Random();
    Vector2 randomVector2KillEffect() => (-Vector2.random(random) - Vector2(-1, -0.5)) * 200;
    
    return ParticleSystemComponent(
      particle: Particle.generate(
        lifespan: 0.1,
        count: 5,
        generator: (i) => AcceleratedParticle(
          position: position,
          acceleration: randomVector2KillEffect(),
          speed: randomVector2KillEffect(),
          child: CircleParticle(
            radius: 1,
            paint: Paint()..color = Colors.red,
          ),
        ),
      ),
    );
  }

}