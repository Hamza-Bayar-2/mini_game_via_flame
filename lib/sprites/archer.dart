import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';

enum ArcherState {attack, death, fall, getHit, idle, jump, run}
enum ArcherDirection {up, down, left, right, upRight, upLeft, downRight, downLeft, none}

class ArcherPlayer extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, KeyboardHandler, TapCallbacks, DragCallbacks{
  ArcherPlayer() : super(position: Vector2(100, 200), size: Vector2.all(200));
  ArcherDirection archerDirection = ArcherDirection.none;
  double speed = 250;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;
  

  @override
  Future<void> onLoad() async {
    _loadAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // by reaching to MiniGame class I used the tapingDownBloc instence that I created there
    // so that I could read the isTapingDown boolean variable
    if(gameRef.tapingDownBloc.state.isTapingDown){
      current = ArcherState.attack;
    } else {
      _archerMovement(dt);
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

    animations = {
      ArcherState.attack: attackAnimation,
      ArcherState.death: deathAnimation,
      ArcherState.fall: fallAnimation,
      ArcherState.getHit: getHitAnimation,
      ArcherState.idle: idleAnimation,
      ArcherState.jump: jumpAnimation,
      ArcherState.run: runAnimation
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
      if (!isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = true;
      }
      current = ArcherState.run;
      directionX += speed;
    } else if (archerDirection == ArcherDirection.left) {
      if (isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = false;
      }
      current = ArcherState.run;
      directionX -= speed;
    } else if(archerDirection == ArcherDirection.upRight){
      if (!isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = true;
      }
      current = ArcherState.run;
      directionY -= speed;
      directionX += speed;
    }
     else if(archerDirection == ArcherDirection.upLeft){
      if (isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = false;
      }
      current = ArcherState.run;
      directionY -= speed;
      directionX -= speed;
    }
     else if(archerDirection == ArcherDirection.downRight){
      if (!isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = true;
      }
      current = ArcherState.run;
      directionX += speed;
      directionY += speed;
    }
     else if(archerDirection == ArcherDirection.downLeft){
      if (isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = false;
      }
      current = ArcherState.run;
      directionX -= speed;
      directionY += speed;
    } else if (archerDirection == ArcherDirection.none) {
      current = ArcherState.idle;
    } else {
      current = ArcherState.idle;
    }

    velocity = Vector2(directionX, directionY);
    position += velocity * dt;
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
  
}