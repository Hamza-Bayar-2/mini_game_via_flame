import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum SkeletonState {run, death, attack}

class Skeleton extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks, HasVisibility{
  bool isSpawnRight;
  Vector2 enemySize;
  Skeleton({
    Vector2? position,
    required this.enemySize,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: enemySize, anchor: anchor);

  double skeletonSpeed = 120;
  bool isSkeletonFacingRight = true;
  bool isDying = false;
  final Timer skeletonDeathTimer = Timer(0.39);
  final Timer bloodTimer = Timer(0.1);
  late final rectangleHitbox = RectangleHitbox.relative(parentSize: enemySize, Vector2(0.15, 0.33))..debugMode = false;

  @override
  FutureOr<void> onLoad() {
    _loadAnimation();
    add(rectangleHitbox);
    deactivate();
    return super.onLoad();
  }

  @override
  void update(double dt) { 
    
    if(gameRef.miniGameBloc.state.isArcherDead || gameRef.miniGameBloc.state.isTheGameReset) {
      deactivate();
    }

    if(isVisible) {
      if(isDying || (gameRef.miniGameBloc.state.gameStage != 4 && gameRef.miniGameBloc.state.gameMode == 0)) {
        _bloodParticles(dt);
        _skeletonDeath(dt);
      } else {
        _skeletonMovement(dt);
      }
    } else {
      bloodTimer.reset();
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Arrow && !isDying){
      isDying = true;
      FlameAudio.play("skeletonDeath.mp3");
    } 
    else if (other is ArcherPlayer) {
      deactivate();
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
  
  void _skeletonMovement(double dt) {
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
        deactivate();
        position = Vector2(gameRef.background.size.x, 0);
      }
    } else {
      directionX += skeletonSpeed;
      if(!isSkeletonFacingRight){
        flipHorizontallyAroundCenter();
        isSkeletonFacingRight = true;
      }
      current = SkeletonState.run;

      if(position.x > gameRef.background.size.x) {
        deactivate();
        position = Vector2(0, 0);
      }
    }

    velocity = Vector2(directionX, 0);
    position.add(velocity * dt);
  }

  void _bloodParticles(double dt) {
    if(bloodTimer.finished){
      bloodTimer.pause();
    } else {  
      bloodTimer.resume();
      bloodTimer.update(dt);
      add(gameRef.bloodParticlesForMonsters(enemySize * 0.45));
    }
  }

  void _skeletonDeath(double dt) {
    rectangleHitbox.collisionType = CollisionType.inactive;
    skeletonDeathTimer.resume();
    skeletonDeathTimer.update(dt);
    current = SkeletonState.death;
    if(skeletonDeathTimer.finished){
      deactivate();
      isDying = false;
      skeletonDeathTimer.stop();
    }
  }

  void activate() {
    isVisible = true;
    rectangleHitbox.collisionType = CollisionType.active;
  } 
  
  void deactivate() {
    isVisible = false;
    rectangleHitbox.collisionType = CollisionType.inactive;
  }
}