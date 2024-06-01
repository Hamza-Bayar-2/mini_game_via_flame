import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';

enum GoblinState {run, death, attack}

class Goblin extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>{
  bool isSpawnRight;
  Goblin({
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: size, anchor: anchor);

  double goblinSpeed = 170;
  bool isGoblinFacingRight = true;
  Vector2 velocity = Vector2.zero();  

  @override
  FutureOr<void> onLoad() {
    _loadAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) { 
    double directionX = 0.0;

    if(isSpawnRight) {
      directionX -= goblinSpeed;  
      if(isGoblinFacingRight){
        flipHorizontallyAroundCenter();
        isGoblinFacingRight = false;
      }
      current = GoblinState.run;

      if(position.x < 0) {
      removeFromParent(); 
    }
    } else {
      directionX += goblinSpeed;
      if(!isGoblinFacingRight){
        flipHorizontallyAroundCenter();
        isGoblinFacingRight = true;
      }
      current = GoblinState.run;

      if(position.x > gameRef.size.x) {
      removeFromParent(); 
    }
    }

    velocity = Vector2(directionX, 0);
    position += velocity * dt;

    super.update(dt);
  }

  void _loadAnimation() {
    double time = 0.1;
    final runAnimation = _spriteAnimation(goblinState: "Run", frameAmount: 8, stepTime: time);
    final deathAnimation = _spriteAnimation(goblinState: "Death", frameAmount: 4, stepTime: time);
    final attackAnimation = _spriteAnimation(goblinState: "Attack", frameAmount: 8, stepTime: time);

    animations = {
      GoblinState.run: runAnimation,
      GoblinState.death: deathAnimation,
      GoblinState.attack: attackAnimation,
    };
  }

  SpriteAnimation _spriteAnimation({required String goblinState, required int frameAmount, required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Enemies/Goblin/$goblinState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(150),
      ),
    );
  }

  

}