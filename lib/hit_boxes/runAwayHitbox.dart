import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class RunAwayHitbox extends RectangleHitbox {
  RunAwayHitbox.relative({
    required Vector2 parentSize,
    required Vector2 relation,
    Vector2? position,
  }) : super.relative(
      relation,
      parentSize: parentSize,
      position: position,
    );
}