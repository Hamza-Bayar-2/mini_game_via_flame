import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';

enum ArcherState {attack, death, fall, getHit, idle, jump, run}
enum ArcherDirection {up, down, left, right, upRight, upLeft, downRight, downLeft, none}

class ArcherPlayer extends SpriteAnimationGroupComponent with HasGameRef, KeyboardHandler, TapCallbacks{
  ArcherPlayer() : super(position: Vector2(100, 200), size: Vector2.all(200));
  ArcherDirection archerDirection = ArcherDirection.none;
  double speed = 250;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;
  bool isTapedDown = false;

  @override
  Future<void> onLoad() async {
    _loadAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _archerMovement(dt);
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

  @override
  void onTapDown(TapDownEvent event) {
    isTapedDown = true;
    super.onTapDown(event);
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
    else {
      archerDirection = ArcherDirection.none;
    }


  }

  // this helps us to manage all the animation that belongs to the archer
  void _loadAnimation() {
    final attackAnimation = _spriteAnimation("Attack", 6);
    final deathAnimation = _spriteAnimation("Death", 10);
    final fallAnimation = _spriteAnimation("Fall", 2);
    final getHitAnimation = _spriteAnimation("Get Hit", 3);
    final idleAnimation = _spriteAnimation("Idle", 10);
    final jumpAnimation = _spriteAnimation("Jump", 2);
    final runAnimation = _spriteAnimation("Run", 8);

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
  SpriteAnimation _spriteAnimation(String archerState, int frameAmount) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Archer/Character/$archerState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: 0.07,
        textureSize: Vector2.all(100),
      ),
    );
  }
  

}