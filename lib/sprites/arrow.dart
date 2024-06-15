import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/flyingEye.dart';
import 'package:mini_game_via_flame/sprites/goblin.dart';
import 'package:mini_game_via_flame/sprites/mushroom.dart';
import 'package:mini_game_via_flame/sprites/skeleton.dart';


class Arrow extends SpriteAnimationComponent with HasGameRef<MiniGame>, CollisionCallbacks, HasVisibility{
  Arrow({
    SpriteAnimation? animation,
    Vector2? position,
    Vector2? size,
    Anchor? anchor
  }) : super(animation: animation, position: position, size: size, anchor: anchor);

  final double _arrowSpeed = 600;
  Vector2 velocity = Vector2.zero();  
  bool isArrowFacingRight = true;
  final Random _random = Random();
  Vector2 randomVector2ForArrow() => (-Vector2.random(_random) - Vector2(1, -0.5)) * 300;
  // the reason why I used variable instead of using it directly inside the "if"
  // because when I do it like that the arrow will change direction 
  // according to the archer even after leaving the bow
  late bool isArcherFacingRight = gameRef.miniGameBloc.state.isPlayerFacingRight;
  late final RectangleHitbox hitbox;

  @override
  FutureOr<void> onLoad() {
    hitbox = RectangleHitbox.relative(parentSize: size, Vector2(1, 1), anchor: Anchor.center)..debugMode = false;
    add(hitbox);
    isVisible = false;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(isVisible) {
      _arrowMovement(dt);
      _arrowParticle();
    } else {
      // this will change the direction of the arrow after the creation
      // without this line the created arrow will not change its direction even if the archer changes her direction
      isArcherFacingRight = gameRef.miniGameBloc.state.isPlayerFacingRight;
      // this will keep the hiden arrows nexto the archer
      // and they will be ready to be throwen
      position = gameRef.archerPlayer.position + Vector2(0, -gameRef.background.size.y * 0.03);
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Goblin || other is Mushroom || other is FlyingEye) {
      hit();
      gameRef.miniGameBloc.add(KillMonster());
    } else if(other is Skeleton) {
      hit();
      if(!other.isShielding) {
        gameRef.miniGameBloc.add(KillMonster());
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void _arrowMovement(double dt) {
    double directionX = 0.0;
    // this for set the arrow direction (right or left)
    if(isArcherFacingRight) {
      directionX += _arrowSpeed;
      if(!isArrowFacingRight) {
        flipHorizontallyAroundCenter();
        isArrowFacingRight = true;
      }
    } else {
      directionX -= _arrowSpeed;
      if(isArrowFacingRight){
        flipHorizontallyAroundCenter();
        isArrowFacingRight = false;
      }
    }

    velocity = Vector2(directionX, 0);
    position.add(velocity * dt);

    if(position.x < 0 || position.x > gameRef.background.size.x) {
      hit();
    }
  }

  void _arrowParticle() {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          lifespan: 0.1,
          count: 2,
          generator: (i) => AcceleratedParticle(
            position: Vector2(0, position.y * 0.01),
            acceleration: randomVector2ForArrow(),
            speed: randomVector2ForArrow(),
            child: CircleParticle(
              radius: 1,
              paint: Paint()..color = Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void fire() {
    isVisible = true;
    hitbox.collisionType = CollisionType.active;
    // print('Arrow fired!');
  }

  void hit() {
    isVisible = false;
    hitbox.collisionType = CollisionType.inactive;
    position = gameRef.archerPlayer.position + Vector2(0, -gameRef.background.size.y * 0.03);
    // print('Arrow hit the target!');
  }

}