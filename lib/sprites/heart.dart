import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';

class Heart extends SpriteAnimationComponent with HasGameRef<MiniGame>, CollisionCallbacks{
  Heart({
    SpriteAnimation? animation,
    Vector2? position,
    Vector2? size,
    Anchor? anchor
  }) : super(animation: animation, position: position, size: size, anchor: anchor);

  Timer heartDisappearTimer = Timer(5);

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox.relative(parentSize: Vector2.all(40), Vector2(1, 1), anchor: Anchor.center));
    return super.onLoad();
  }

  @override
  void update(double dt) {

    _heartDisappear(dt);

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is ArcherPlayer){
      gameRef.miniGameBloc.add(IncreaseHealthEvent());
      FlameAudio.play("powerUp.mp3");
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
  
  void _heartDisappear(double dt) {
    heartDisappearTimer.resume();
    heartDisappearTimer.update(dt);

    if(heartDisappearTimer.finished){
      removeFromParent();
    }
  }




}