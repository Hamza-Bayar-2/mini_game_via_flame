import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum SkeletonState {run, death, attack}

class Skeleton extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks{
  bool isSpawnRight;
  Skeleton({
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: size, anchor: anchor);

  double skeletonSpeed = 120;
  bool isSkeletonFacingRight = true;
  bool isDying = false;
  final Timer skeletonDeathTimer = Timer(0.39);
  final rectangleHitbox = RectangleHitbox.relative(parentSize: Vector2.all(280), Vector2(0.15, 0.33), position: Vector2(120, 95));

  @override
  FutureOr<void> onLoad() {
    _loadAnimation();
    add(rectangleHitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) { 
    
    if(gameRef.miniGameBloc.state.isArcherDead) {
      removeFromParent();
    }

    if(isDying || gameRef.miniGameBloc.state.isArcherDead || gameRef.miniGameBloc.state.gameStage != 4) {
      rectangleHitbox.removeFromParent();
      skeletonDeathTimer.resume();
      skeletonDeathTimer.update(dt);
      current = SkeletonState.death;
      if(skeletonDeathTimer.finished){
        removeFromParent();
        skeletonDeathTimer.stop();
      }
    } else {

      _skeletonSpawner(dt);

    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Arrow && !isDying){
      isDying = true;
      FlameAudio.play("monsterDeath.mp3");
    } 
    else if (other is ArcherPlayer) {
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
  
  void _loadAnimation() {
    double time = 0.1;
    final runAnimation = _spriteAnimation(skeletonState: "Walk", frameAmount: 4, stepTime: time * 1.5);
    final deathAnimation = _spriteAnimation(skeletonState: "Death", frameAmount: 4, stepTime: time);
    final attackAnimation = _spriteAnimation(skeletonState: "Attack", frameAmount: 8, stepTime: time);

    animations = {
      SkeletonState.run: runAnimation,
      SkeletonState.death: deathAnimation,
      SkeletonState.attack: attackAnimation,
    };
  }

  SpriteAnimation _spriteAnimation({required String skeletonState, required int frameAmount, required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Enemies/Skeleton/$skeletonState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(150),
      ),
    );
  }
  
  void _skeletonSpawner(double dt) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;

    if(isSpawnRight) {
      directionX -= skeletonSpeed;  
      if(isSkeletonFacingRight){
        flipHorizontallyAroundCenter();
        isSkeletonFacingRight = false;
      }
      current = SkeletonState.run;

      if(position.x < 0) {
      removeFromParent(); 
    }
    } else {
      directionX += skeletonSpeed;
      if(!isSkeletonFacingRight){
        flipHorizontallyAroundCenter();
        isSkeletonFacingRight = true;
      }
      current = SkeletonState.run;

      if(position.x > gameRef.size.x) {
        removeFromParent(); 
      }
    }

    velocity = Vector2(directionX, 0);
    position += velocity * dt;
  }
}