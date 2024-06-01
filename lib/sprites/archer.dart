import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';

enum ArcherState {attack, death, fall, getHit, idle, jump, run, deathStatic}
enum ArcherDirection {up, down, left, right, upRight, upLeft, downRight, downLeft, none}

class ArcherPlayer extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, KeyboardHandler, TapCallbacks, DragCallbacks{
  ArcherPlayer() : super(position: Vector2.all(500), size: Vector2.all(200), anchor: Anchor.centerRight);
  ArcherDirection archerDirection = ArcherDirection.none;
  double speed = 250;
  // When the player runs diagonally, this value will be used
  // 250*250 = x*x + x*x, x = hypotenuseSpeed
  late double hypotenuseSpeed = sqrt(speed*speed/2);
  Vector2 velocity = Vector2.zero();
  // this timer is used for the archer death animation
  final countdown = Timer(0.7);
  bool isDeathAudioPlayed = false;
  bool isArcherRunning = false;
  late Bgm runSoundBmg = FlameAudio.bgmFactory(audioCache: FlameAudio.audioCache);

  @override
  Future<void> onLoad() async {
    _loadAnimation();
    return super.onLoad();
  }

  @override
  Future<void> update(double dt) async {
    // by reaching to MiniGame class, I ma usign the miniGameBloc instence that I created there
    // so I could read the isTapingDown boolean variable
    if(gameRef.miniGameBloc.state.isArcherDead) {
      _killArcher(dt);
      isArcherRunning = false;
      runSoundBmg.stop();
    } else if(gameRef.miniGameBloc.state.isTapingDown){
      countdown.stop();
      current = ArcherState.attack;
      isArcherRunning = false;
      runSoundBmg.stop();
    } else {
      countdown.stop();
      _archerMovement(dt);
      _archerRunningSound();
    }
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

    _keyBoardDirectionHandler(
      isUpKeyPressed, 
      isDownKeyPressed, 
      isRightKeyPressed, 
      isLeftKeyPressed
    );

    return super.onKeyEvent(event, keysPressed);
  }

  // this method make the archer move according to the keys that pressed
  void _keyBoardDirectionHandler(
    bool isUpKeyPressed, 
    bool isDownKeyPressed, 
    bool isRightKeyPressed, 
    bool isLeftKeyPressed, 
    ) {
    if(isUpKeyPressed && isDownKeyPressed){
      archerDirection = ArcherDirection.none;
    } else if(isRightKeyPressed && isLeftKeyPressed){
      archerDirection = ArcherDirection.none;
    } 
    else if(isUpKeyPressed && isRightKeyPressed) {
      archerDirection = ArcherDirection.upRight;
    } else if(isUpKeyPressed && isLeftKeyPressed) {
      archerDirection = ArcherDirection.upLeft;
    } else if(isDownKeyPressed && isRightKeyPressed) {
      archerDirection = ArcherDirection.downRight;
    } else if(isDownKeyPressed && isLeftKeyPressed) {
      archerDirection = ArcherDirection.downLeft;
    } 
    else if(isUpKeyPressed){
      archerDirection = ArcherDirection.up;
    } else if(isDownKeyPressed){
      archerDirection = ArcherDirection.down;
    } else if(isRightKeyPressed){
      archerDirection = ArcherDirection.right;
    } else if(isLeftKeyPressed){
      archerDirection = ArcherDirection.left;
    } 
    else{
      archerDirection = ArcherDirection.none;
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

  // This method can make the archer moves according to the ArcherDirection enum
  void _archerMovement(double dt) {
    double directionX = 0.0, directionY = 0.0;

    if (archerDirection == ArcherDirection.up) {
      current = ArcherState.run;
      directionY -= speed;
    } else if (archerDirection == ArcherDirection.down) {
      current = ArcherState.run;
      directionY += speed;
    } else if (archerDirection == ArcherDirection.right) {
      if (!gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceRightEvent());
      }
      current = ArcherState.run;
      directionX += speed;
    } else if (archerDirection == ArcherDirection.left) {
      if (gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceLeftEvent());
      }
      current = ArcherState.run;
      directionX -= speed;
    } else if(archerDirection == ArcherDirection.upRight){
      if (!gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceRightEvent());
      }
      current = ArcherState.run;
      directionY -= hypotenuseSpeed;
      directionX += hypotenuseSpeed;
    }
     else if(archerDirection == ArcherDirection.upLeft){
      if (gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceLeftEvent());
      }
      current = ArcherState.run;
      directionY -= hypotenuseSpeed;
      directionX -= hypotenuseSpeed;
    }
     else if(archerDirection == ArcherDirection.downRight){
      if (!gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceRightEvent());
      }
      current = ArcherState.run;
      directionX += hypotenuseSpeed;
      directionY += hypotenuseSpeed;
    }
     else if(archerDirection == ArcherDirection.downLeft){
      if (gameRef.miniGameBloc.state.isPlayerFacingRight) {
        flipHorizontallyAroundCenter();
        gameRef.miniGameBloc.add(FaceLeftEvent());
      }
      current = ArcherState.run;
      directionX -= hypotenuseSpeed;
      directionY += hypotenuseSpeed;
    } else if (archerDirection == ArcherDirection.none) {
      current = ArcherState.idle;
    } else {
      current = ArcherState.idle;
    }

    velocity = Vector2(directionX, directionY);
    position += velocity * dt;

    // this keeps the archer inseade the screen
    position.clamp(Vector2.zero(), Vector2(gameRef.size.x, gameRef.size.y));
  }
 
  // this method is used to prevent repeating the same code
  // An animation is created by giving the name of the file and the number of the frames in the sheet
  SpriteAnimation _spriteAnimation({required String archerState, required int frameAmount, required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Archer/Character/$archerState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2(100,100),
      ),
    );
  }
  
  void _killArcher(double dt) {
    countdown.resume();
    countdown.update(dt);
      // untel the time is up the current state will be the death state
      // when the time is up the current state will be the deathStatic state
      if(countdown.finished){
        current = ArcherState.deathStatic;
        isDeathAudioPlayed = false;
      } else {
        if(!isDeathAudioPlayed){
          FlameAudio.play("death.mp3");
          isDeathAudioPlayed = true;
        }
        current = ArcherState.death;
    }    
  }

  void _archerRunningSound() {
    if(current != ArcherState.idle && !isArcherRunning){
      runSoundBmg.play("running.mp3");
      isArcherRunning = true;
    } else if (current == ArcherState.idle){
      isArcherRunning = false;
      runSoundBmg.stop();
    }
  }
}