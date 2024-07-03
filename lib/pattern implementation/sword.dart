import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';

class Sword extends PositionComponent with CollisionCallbacks, HasGameRef<MiniGame> {
  late final RectangleHitbox swordHitbox;

  Sword({required Vector2 size, 
  required Anchor anchor}) : super(size: size, anchor: anchor);

  @override
  FutureOr<void> onLoad() {
    swordHitbox = RectangleHitbox.relative(
      Vector2(0.4, 0.4),
      parentSize: size,
      anchor: anchor,
    )..debugMode = true;
    add(swordHitbox);
    return super.onLoad();
  }
  

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is ArcherPlayer) {

    }
    super.onCollision(intersectionPoints, other);
  }
}
