import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flame/rendering.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:flutter/src/widgets/focus_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/pools/arrow_pool.dart';
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

class MiniGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks, HasCollisionDetection, HasDecorator{
  final MiniGameBloc miniGameBloc;
  MiniGame({required this.miniGameBloc});
  
  late final SpriteComponent background;
  late final ArcherPlayer archerPlayer;
  // 0.72 seconds is the frame amount of the attack animation multiplies by step time (6 * 0.12)
  // The purpose of this timer is to ensure that arrows are released at the right time 
  // in the archer's attack animation. 
  final Timer countdownAndRepeat = Timer(0.72);
  late Bgm backgroundMusic = FlameAudio.bgmFactory(audioCache: FlameAudio.audioCache); 
  final double heartSpawnPeriod = 7.5;
  late SpawnComponent heartSpawner;
  late SpawnComponent enemySpawner1;
  late SpawnComponent enemySpawner2;
  late bool wasArcherDead = miniGameBloc.state.isArcherDead;
  late int previousDifficultyLevel = miniGameBloc.state.difficultyLevel;
  late int previousArcherHealth = miniGameBloc.state.archerHelth;
  // late final Decorator decoratorForArcher;
  late final CameraComponent cameraComponent;
  @override
  late final World world;
  final archerScale = 0.3;
  final monstersScale = 0.44;
  final arrowScale = 0.35;
  final heartScale = 0.05;
  late final ArrowPool arrowPool;
  late Arrow arrow;

  @override
  Future<void> onLoad() async{
    await FlameAudio.audioCache.loadAll(['running.mp3', 'arrow.mp3', 'death.mp3', 'hurt.mp3', 'monsterDeath.mp3', 'bgm.mp3', 'powerUp.mp3', 'win.mp3', 'lose.mp3', 'skeletonDeath.mp3', 'skeletonDeath2.mp3', 'mushroomDeath.mp3', 'flyingEyeDeath.mp3']);
    await images.loadAllImages();
    background = SpriteComponent(sprite: Sprite(images.fromCache("background.png")), size: size);
    archerPlayer = ArcherPlayer(size: Vector2.all(background.size.y * archerScale), position: Vector2(background.size.x / 2, background.size.y / 2));
    heartSpawner = _heartCreater();
    enemySpawner1 = _enemyCreater(true, Vector2.all(background.size.y * monstersScale), background.size.x);
    enemySpawner2 = _enemyCreater(false, Vector2.all(background.size.y * monstersScale), 0);
    arrowPool = ArrowPool();

    world = World(children: [background, archerPlayer, heartSpawner, enemySpawner1, enemySpawner2, arrowPool]);
    await add(world); 
    cameraComponent = CameraComponent.withFixedResolution(
      width: size.x,
      height: size.y,
      world: world
    );
    await add(cameraComponent);
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
    _removeComponentWhenArcherDeadAndAddComponentWhenArcherRevive();
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

    if(keysPressed.contains(LogicalKeyboardKey.escape)){
      miniGameBloc.add(GoToPausePage());
    }
    return super.onKeyEvent(event, keysPressed);
  }

  Future<void> _arrowManager(double dt) async {
    if((miniGameBloc.state.isSpaceKeyPressing) && !miniGameBloc.state.isArcherDead) {
      countdownAndRepeat.update(dt);
      countdownAndRepeat.resume();
      // when the time is up the arrow will be throwen
      if(countdownAndRepeat.finished) {
        arrow = arrowPool.acquire();
        // the retun arrow could be a new arrow
        // so first we check if the world has this arrow, if not we add it to the world
        if(!world.children.contains(arrow)) {
          await world.add(arrow);
        }
        // after the arrow is ready it will be fired
        arrow.fire();
        FlameAudio.play("arrow.mp3");
        countdownAndRepeat.start();
        // from here we can check how many arrow dose the pool has
        print(arrowPool.poolLength);
      }
    } else {
      countdownAndRepeat.stop();
    } 
  }

  SpawnComponent _enemyCreater(bool isSpawnRight, Vector2 enemySize, double positionX) {
    return SpawnComponent(
        factory: (index) {
          return _enemyPickerForEnemyCreaterMethod(isSpawnRight, enemySize)..debugMode = false;
        },
        period: miniGameBloc.state.enemySpawnPeriod,
        area: Rectangle.fromLTWH(positionX, 30, 0, background.size.y - 50),
    );
  }

  dynamic _enemyPickerForEnemyCreaterMethod(bool isSpawnRight, Vector2 enemySize) {
    if(miniGameBloc.state.gameStage == 1) {
      return Goblin(isSpawnRight: isSpawnRight, enemySize: enemySize);
    } else if(miniGameBloc.state.gameStage == 2) {
      return Mushroom(isSpawnRight: isSpawnRight, enemySize: enemySize);
    } else if(miniGameBloc.state.gameStage == 3) {
      return FlyingEye(isSpawnRight: isSpawnRight, enemySize: enemySize);
    } else if(miniGameBloc.state.gameStage == 4) {
      return Skeleton(isSpawnRight: isSpawnRight, enemySize: enemySize);
    } 
    else {
      return Goblin(isSpawnRight: isSpawnRight, enemySize: enemySize);
    }
  }

  SpawnComponent _heartCreater() {
    return SpawnComponent(
      factory: (index) {
        return Heart(animation: _heartAnimation(), anchor: Anchor.center, size: Vector2.all(background.size.y * heartScale));
      },
      period: heartSpawnPeriod,
      area: Rectangle.fromLTWH(background.size.x / 12, background.size.y / 12, background.size.x * 0.8, background.size.y * 0.8),
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
      enemySpawner1 = _enemyCreater(true, Vector2.all(background.size.y * monstersScale), background.size.x);
      enemySpawner2 = _enemyCreater(false, Vector2.all(background.size.y * monstersScale), 0);

      world.addAll({heartSpawner, enemySpawner1, enemySpawner2});
    }

    wasArcherDead = miniGameBloc.state.isArcherDead;
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
      _removeAndAddEnemySpawner();

    } else if(miniGameBloc.state.monsterKillNumber % 40 == 20 && miniGameBloc.state.gameStage == 2) {
      // game stage will be 3
      miniGameBloc.add(NextGameStageEvent());
      _removeAndAddEnemySpawner();

    } else if(miniGameBloc.state.monsterKillNumber % 40 == 30 && miniGameBloc.state.gameStage == 3) {
      // game stage will be 4 (final stage)
      miniGameBloc.add(NextGameStageEvent());
      _removeAndAddEnemySpawner();

    } else if(miniGameBloc.state.monsterKillNumber % 40 == 0 && miniGameBloc.state.gameStage == 4) {
      // game stage will be reset to 1 
      miniGameBloc.add(ResetGameStageEvent());
      _removeAndAddEnemySpawner();
      
      // if the player plays gameMode 0 (finite mode) he will win the game
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

    enemySpawner1 = _enemyCreater(true, Vector2.all(background.size.y * monstersScale), background.size.x,);
    enemySpawner2 = _enemyCreater(false, Vector2.all(background.size.y * monstersScale), 0);

    world.addAll({enemySpawner1, enemySpawner2}); 

    print("ekleme yapildi");
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
      
      // this make the isTheGamereset => false
      miniGameBloc.add(NotResetAllGameEvent());

      _removeAndAddEnemySpawner();

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