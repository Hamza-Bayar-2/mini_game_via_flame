import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/rendering.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/hit_boxes/killHitbox.dart';
import 'package:mini_game_via_flame/sprites/flyingEye.dart';
import 'package:mini_game_via_flame/sprites/goblin.dart';
import 'package:mini_game_via_flame/sprites/heart.dart';
import 'package:mini_game_via_flame/sprites/mushroom.dart';
import 'package:mini_game_via_flame/sprites/skeleton.dart';

enum ArcherState {attack, death, fall, getHit, idle, jump, run, deathStatic}
enum PressedKey {up, down, left, right, upRight, upLeft, downRight, downLeft, space, none}

class ArcherPlayer extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, KeyboardHandler, TapCallbacks, DragCallbacks,
 CollisionCallbacks{
  ArcherPlayer({required Vector2 size, required Vector2 position}) : super(position: position, size: size, anchor: Anchor.center);
  PressedKey pressedKey = PressedKey.none;
  double speed = 250;
  // When the player runs diagonally, this value will be used
  // 250*250 = x*x + x*x, x = hypotenuseSpeed
  late double hypotenuseSpeed = sqrt(speed*speed/2);
  Vector2 velocity = Vector2.zero();
  // this timer is used for the archer death animation
  final archerDeathCountdown = Timer(0.7);
  final archerGetHitCountdown = Timer(0.21);
  final archerHelathIncreaseCountdown = Timer(0.4);
  bool isArcherHealthIncreased = false;
  bool isDeathAudioPlayed = false;
  bool isArcherRunning = false;
  bool isArcherGetHit = false;
  late Bgm runSoundBmg = FlameAudio.bgmFactory(audioCache: FlameAudio.audioCache);
  final cameraShake = MoveEffect.by(
    Vector2.all(20), 
    InfiniteEffectController(ZigzagEffectController(period: 0.2))
  );
  late int previousArcherHealth = gameRef.miniGameBloc.state.archerHelth;
  late final Decorator decoratorForArcher;


  @override
  Future<void> onLoad() async {
    _loadAnimation();
    add(RectangleHitbox.relative(Vector2(0.25,0.30), parentSize: size, anchor: Anchor.center));
    gameRef.cameraComponent.viewfinder.add(cameraShake);
    cameraShake.pause();
    // this decorator belongs to the archer
    decoratorForArcher = decorator;
    return super.onLoad();
  }

  @override
  Future<void> update(double dt) async {
    // by reaching to MiniGame class, I ma usign the miniGameBloc instence that I created there
    // so I could read the isTapingDown boolean variable
    if(gameRef.miniGameBloc.state.isArcherDead) {
      _killArcher(dt);
      gameRef.miniGameBloc.add(ResetGameStageEvent());
      runSoundBmg.stop();
      isArcherGetHit = false;
    } else if(isArcherGetHit) {
      _archerGetHit(dt); 
    } else {
      archerDeathCountdown.stop();
      _archerMovement(dt);
      _archerRunningSound();
    }

    _updateArcherDecorator(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowUp) || 
    keysPressed.contains(LogicalKeyboardKey.keyW);
    final isDownKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowDown) || 
    keysPressed.contains(LogicalKeyboardKey.keyS);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowRight) || 
    keysPressed.contains(LogicalKeyboardKey.keyD);
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft) || 
    keysPressed.contains(LogicalKeyboardKey.keyA);
    final isSpaceKeyPressed = keysPressed.contains(LogicalKeyboardKey.space);

    _keyBoardDirectionHandler(
      isUpKeyPressed, 
      isDownKeyPressed, 
      isRightKeyPressed, 
      isLeftKeyPressed,
      isSpaceKeyPressed
    );

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Goblin || other is Mushroom || other is Skeleton || other is FlyingEye) {
      cameraShake.resume();
      gameRef.miniGameBloc.add(DecreaseHealthEvent());
      isArcherGetHit = true;
    } else if(other is Heart) {
      isArcherHealthIncreased = true;
    }
    cameraShake.pause();
    super.onCollision(intersectionPoints, other);
  }
  
  // this method make the archer move according to the keys that pressed
  void _keyBoardDirectionHandler(
    bool isUpKeyPressed, 
    bool isDownKeyPressed, 
    bool isRightKeyPressed, 
    bool isLeftKeyPressed, 
    bool isSpaceKeyPressed
    ) {

    if(isSpaceKeyPressed){
      pressedKey = PressedKey.space;
    }
    else if(isUpKeyPressed && isDownKeyPressed){
      pressedKey = PressedKey.none;
    } else if(isRightKeyPressed && isLeftKeyPressed){
      pressedKey = PressedKey.none;
    } 
    else if(isUpKeyPressed && isRightKeyPressed) {
      pressedKey = PressedKey.upRight;
    } else if(isUpKeyPressed && isLeftKeyPressed) {
      pressedKey = PressedKey.upLeft;
    } else if(isDownKeyPressed && isRightKeyPressed) {
      pressedKey = PressedKey.downRight;
    } else if(isDownKeyPressed && isLeftKeyPressed) {
      pressedKey = PressedKey.downLeft;
    } 
    else if(isUpKeyPressed){
      pressedKey = PressedKey.up;
    } else if(isDownKeyPressed){
      pressedKey = PressedKey.down;
    } else if(isRightKeyPressed){
      pressedKey = PressedKey.right;
    } else if(isLeftKeyPressed){
      pressedKey = PressedKey.left;
    } 
    else{
      pressedKey = PressedKey.none;
    } 
  }

  // this helps us to manage all the animation that belongs to the archer
  void _loadAnimation() {
    double time = 0.07;
    final attackAnimation = _spriteAnimation(archerState: "Attack", frameAmount: 6, stepTime: 0.12);
    final deathAnimation = _spriteAnimation(archerState: "Death", frameAmount: 10, stepTime: time);
    final fallAnimation = _spriteAnimation(archerState: "Fall", frameAmount: 2, stepTime: time);
    final getHitAnimation = _spriteAnimation(archerState: "Get Hit", frameAmount: 3, stepTime: time);
    final idleAnimation = _spriteAnimation(archerState: "Idle", frameAmount: 10, stepTime: time);
    final jumpAnimation = _spriteAnimation(archerState: "Jump", frameAmount: 2, stepTime: time);
    final runAnimation = _spriteAnimation(archerState: "Run", frameAmount: 8, stepTime: time);
    final lastFrameDeath = _spriteAnimation(archerState: "DeathStatic", frameAmount: 1, stepTime: 10);

    animations = {
      ArcherState.attack: attackAnimation,
      ArcherState.death: deathAnimation,
      ArcherState.fall: fallAnimation,
      ArcherState.getHit: getHitAnimation,
      ArcherState.idle: idleAnimation,
      ArcherState.jump: jumpAnimation,
      ArcherState.run: runAnimation,
      ArcherState.deathStatic: lastFrameDeath
    };
  }

  // This method can make the archer moves according to the PressedKey enum
  void _archerMovement(double dt) {
    double directionX = 0.0, directionY = 0.0;

    if (pressedKey == PressedKey.up) {
      current = ArcherState.run;
      directionY -= speed;
    } else if (pressedKey == PressedKey.down) {
      current = ArcherState.run;
      directionY += speed;
    } else if (pressedKey == PressedKey.right) {
      if (!gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceRightEvent());
      }
      current = ArcherState.run;
      directionX += speed;
    } else if (pressedKey == PressedKey.left) {
      if (gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceLeftEvent());
      }
      current = ArcherState.run;
      directionX -= speed;
    } 
    else if(pressedKey == PressedKey.upRight){
      if (!gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceRightEvent());
      }
      current = ArcherState.run;
      directionY -= hypotenuseSpeed;
      directionX += hypotenuseSpeed;
    }
     else if(pressedKey == PressedKey.upLeft){
      if (gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceLeftEvent());
      }
      current = ArcherState.run;
      directionY -= hypotenuseSpeed;
      directionX -= hypotenuseSpeed;
    }
     else if(pressedKey == PressedKey.downRight){
      if (!gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceRightEvent());
      }
      current = ArcherState.run;
      directionX += hypotenuseSpeed;
      directionY += hypotenuseSpeed;
    }
     else if(pressedKey == PressedKey.downLeft){
      if (gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceLeftEvent());
      }
      current = ArcherState.run;
      directionX -= hypotenuseSpeed;
      directionY += hypotenuseSpeed;
    } 
    else if (pressedKey == PressedKey.none) {
      current = ArcherState.idle;
    } 
    else if(pressedKey == PressedKey.space){
      current = ArcherState.attack;
    } 
    else {
      current = ArcherState.idle;
    }

    velocity = Vector2(directionX, directionY);
    position.add(velocity * dt);

    // this keeps the archer inseade the screen
    position.clamp(size - (size / 1.2), Vector2(gameRef.background.size.x, gameRef.background.size.y) - (size / 6));
  }
 
  // this method is used to prevent repeating the same code
  // An animation is created by giving the name of the file and the number of the frames in the sheet
  SpriteAnimation _spriteAnimation({required String archerState, required int frameAmount, required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Archer/Character/$archerState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(100),
      ),
    );
  }
  
  void _killArcher(double dt) {
    archerDeathCountdown.resume();
    archerDeathCountdown.update(dt);
    // untel the time is up the current state will be the death state
    // when the time is up the current state will be the deathStatic state
    if(archerDeathCountdown.finished){
      FlameAudio.play("lose.mp3", volume: 0.5);
      current = ArcherState.deathStatic;
      isDeathAudioPlayed = false;
      gameRef.miniGameBloc.add(GoToWinOrLosePage());
      // if this line uncommented the death animation will be repeating constantly
      // archerDeathCountdown.stop();
    } else {
      if(!isDeathAudioPlayed){
        FlameAudio.play("death.mp3");
        isDeathAudioPlayed = true;
      }
      current = ArcherState.death;
    }    
  }

  void _archerRunningSound() {
    if(current != ArcherState.idle && current != ArcherState.attack && !isArcherRunning) {
      runSoundBmg.play("running.mp3");
      isArcherRunning = true;
    } else if (current == ArcherState.idle || current == ArcherState.attack || gameRef.miniGameBloc.state.flutterPage != 1){
      isArcherRunning = false;
      runSoundBmg.stop();
    }
  }
  
  void _archerGetHit(double dt) {
    cameraShake.resume();
    current = ArcherState.getHit;
    archerGetHitCountdown.resume();
    archerGetHitCountdown.update(dt);
    if(archerGetHitCountdown.finished){
      cameraShake.pause();
      FlameAudio.play("hurt.mp3");
      isArcherGetHit = false;
      archerGetHitCountdown.stop();
    }
  }

  void _updateArcherDecorator(double dt) {
  archerHelathIncreaseCountdown.update(dt);

  bool isLowHealth = gameRef.miniGameBloc.state.archerHelth <= 20;
  
  if (isArcherHealthIncreased) {
    // Apply green tint when health is increased
    archerHelathIncreaseCountdown.start();
    decoratorForArcher.replaceLast(PaintDecorator.tint(const Color.fromARGB(143, 92, 255, 92)));
    isArcherHealthIncreased = false;
  } else if (archerHelathIncreaseCountdown.finished) {
    // Revert to red tint if health is low, or clear the tint if health is not low
    if (isLowHealth) {
      decoratorForArcher.replaceLast(PaintDecorator.tint(const Color.fromARGB(93, 255, 0, 0)));
    } else {
      decoratorForArcher.replaceLast(null);
    }
    archerHelathIncreaseCountdown.stop();
  } else if (isLowHealth && previousArcherHealth != gameRef.miniGameBloc.state.archerHelth && !gameRef.miniGameBloc.state.isArcherDead) {
    // Apply red tint when health is low
    decoratorForArcher.replaceLast(PaintDecorator.tint(const Color.fromARGB(93, 255, 0, 0)));
  } else if (!isLowHealth && previousArcherHealth != gameRef.miniGameBloc.state.archerHelth) {
    // Remove the tint if the health is no longer low and health is not increased
    decoratorForArcher.replaceLast(null);
  }

  previousArcherHealth = gameRef.miniGameBloc.state.archerHelth;
}


}