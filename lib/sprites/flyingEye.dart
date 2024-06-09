import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum FlyingEyeState {run, death, attack}

class FlyingEye extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks{
  bool isSpawnRight;
  FlyingEye({
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: size, anchor: anchor);

  double flyingEyeSpeed = 150;
  bool isFlyingEyeFacingRight = true;
  bool isDying = false;
  // the timer is a bit less than the death time, 
  // because the death animation repeats a bit
  final Timer flyingEyeDeathTimer = Timer(0.39);
  final Timer bloodTimer = Timer(0.1);
  final rectangleHitbox = RectangleHitbox.relative(parentSize: Vector2.all(280), Vector2(0.22, 0.15), position: Vector2(115, 124));

  @override
  Future<void> onLoad() async {
    _loadAnimation();
    add(rectangleHitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) { 
    
    if(gameRef.miniGameBloc.state.isArcherDead || gameRef.miniGameBloc.state.isTheGameReset) {
      removeFromParent();
    }

    if(isDying || gameRef.miniGameBloc.state.gameStage != 3) {

      if(bloodTimer.finished){
        bloodTimer.pause();
      } else {  
        bloodTimer.resume();
        bloodTimer.update(dt);
        add(gameRef.bloodParticlesForMonsters(Vector2.all(150)));
      }

      rectangleHitbox.removeFromParent();
      flyingEyeDeathTimer.resume();
      flyingEyeDeathTimer.update(dt);
      current = FlyingEyeState.death;
      if(flyingEyeDeathTimer.finished){
        removeFromParent();
        flyingEyeDeathTimer.stop();
      }
    } else {

      _flyingEyeSpawner(dt);

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
  
  void _flyingEyeSpawner(double dt) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;

    if(isSpawnRight) {
      directionX -= flyingEyeSpeed;  
      if(isFlyingEyeFacingRight){
        flipHorizontallyAroundCenter();
        isFlyingEyeFacingRight = false;
      }
      current = FlyingEyeState.run;

      if(position.x < 0) {
      removeFromParent(); 
    }
    } else {
      directionX += flyingEyeSpeed;
      if(!isFlyingEyeFacingRight){
        flipHorizontallyAroundCenter();
        isFlyingEyeFacingRight = true;
      }
      current = FlyingEyeState.run;

      if(position.x > gameRef.background.size.x) {
        removeFromParent(); 
      }
    }

    velocity = Vector2(directionX, 0);
    position.add(velocity * dt);
  }
}