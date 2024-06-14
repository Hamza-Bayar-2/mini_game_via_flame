import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum FlyingEyeState {run, death, attack}

class FlyingEye extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks, HasVisibility{
  bool isSpawnRight;
  Vector2 enemySize;
  FlyingEye({
    Vector2? position,
    required this.enemySize,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: enemySize, anchor: anchor);

  double flyingEyeSpeed = 150;
  double flyingEyeSpeedUpScale = 120;
  bool isFlyingEyeFacingRight = true;
  bool isDying = false;
  // the timer is a bit less than the death time, 
  // because the death animation repeats a bit
  final Timer flyingEyeDeathTimer = Timer(0.39);
  final Timer bloodTimer = Timer(0.1);
  late final rectangleHitbox = RectangleHitbox.relative(parentSize: enemySize, Vector2(0.22, 0.15))..debugMode = false;
  final bool isFlyingEyeGoingFast = Random().nextInt(100) < 35;

  @override
  Future<void> onLoad() async {
    _loadAnimation();
    add(rectangleHitbox);
    deactivate();
    return super.onLoad();
  }

  @override
  void update(double dt) { 
    
    if(gameRef.miniGameBloc.state.isArcherDead || gameRef.miniGameBloc.state.isTheGameReset) {
      // removeFromParent();
      deactivate();
    }

    if(isVisible) {
      if(isDying || (gameRef.miniGameBloc.state.gameStage != 3 && gameRef.miniGameBloc.state.gameMode == 0)) {
        _bloodParticles(dt);
        _flyingEyeDeath(dt);
      } else {
        _flyingEyeMovement(dt);
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
      FlameAudio.play("flyingEyeDeath.mp3", volume: 0.7);
    } 
    else if (other is ArcherPlayer) {
      // removeFromParent();
      deactivate();
    }
    super.onCollision(intersectionPoints, other);
  }
  
  void _loadAnimation() {
    double time = 0.1;
    final runAnimation = _spriteAnimation(flyingEyeState: "Flight", frameAmount: 8, stepTime: time);
    final deathAnimation = _spriteAnimation(flyingEyeState: "Death", frameAmount: 4, stepTime: time);
    final attackAnimation = _spriteAnimation(flyingEyeState: "Attack", frameAmount: 8, stepTime: time);

    animations = {
      FlyingEyeState.run: runAnimation,
      FlyingEyeState.death: deathAnimation,
      FlyingEyeState.attack: attackAnimation,
    };
  }

  SpriteAnimation _spriteAnimation({required String flyingEyeState, required int frameAmount, required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Enemies/Flying eye/$flyingEyeState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(150),
      ),
    );
  }
  
  void _flyingEyeMovement(double dt) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;

    if(isSpawnRight) {
      if(isFlyingEyeFacingRight){
        flipHorizontallyAroundCenter();
        isFlyingEyeFacingRight = false;
      }
      current = FlyingEyeState.run;
      directionX -= isFlyingEyeGoingFast ? flyingEyeSpeed + flyingEyeSpeedUpScale : flyingEyeSpeed;  

      if(position.x < 0) {
        // removeFromParent(); 
        deactivate();
        position = Vector2(gameRef.background.size.x, 0);
      }
    } else {
      if(!isFlyingEyeFacingRight){
        flipHorizontallyAroundCenter();
        isFlyingEyeFacingRight = true;
      }
      current = FlyingEyeState.run;
      directionX += isFlyingEyeGoingFast ? flyingEyeSpeed + flyingEyeSpeedUpScale : flyingEyeSpeed;

      if(position.x > gameRef.background.size.x) {
        // removeFromParent(); 
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

  void _flyingEyeDeath(double dt) {
    // rectangleHitbox.removeFromParent();
    rectangleHitbox.collisionType = CollisionType.inactive;
    flyingEyeDeathTimer.resume();
    flyingEyeDeathTimer.update(dt);
    current = FlyingEyeState.death;
    if(flyingEyeDeathTimer.finished){
      // removeFromParent();
      deactivate();
      isDying = false;
      flyingEyeDeathTimer.stop();
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