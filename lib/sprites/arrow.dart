import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/flyingEye.dart';
import 'package:mini_game_via_flame/sprites/goblin.dart';
import 'package:mini_game_via_flame/sprites/mushroom.dart';
import 'package:mini_game_via_flame/sprites/skeleton.dart';



class Arrow extends SpriteAnimationComponent with HasGameRef<MiniGame>, CollisionCallbacks{
  Arrow({
    SpriteAnimation? animation,
    Vector2? position,
    Vector2? size,
    Anchor? anchor
  }) : super(animation: animation, position: position, size: size, anchor: anchor);

  final double _arrowSpeed = 600;
  Vector2 velocity = Vector2.zero();  
  bool isArrowFacingRight = true;

  // the reason why I used variable instead of using it directly inside the "if"
  // because when I do it like that the arrow will change direction 
  // according to the archer even after leaving the bow
  late bool isArcherFacingRight = gameRef.miniGameBloc.state.isPlayerFacingRight;
  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox.relative(parentSize: Vector2(48, 10), Vector2(1, 1), anchor: Anchor.center));
    return super.onLoad();
  }

  @override
  void update(double dt) {
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
    position += velocity * dt;

    if(position.x < 0 || position.x > gameRef.size.x) {
      removeFromParent(); 
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Goblin || other is Mushroom || other is Skeleton || other is FlyingEye) {
      removeFromParent();
      gameRef.miniGameBloc.add(KillMonster());
      print("arrow hited");
    }
    super.onCollision(intersectionPoints, other);
  }
}