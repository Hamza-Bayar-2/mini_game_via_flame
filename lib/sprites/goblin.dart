import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum GoblinState {run, death, attack}

class Goblin extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks{
  bool isSpawnRight;
  Goblin({
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: size, anchor: anchor);

  double goblinSpeed = 160;
  bool isGoblinFacingRight = true;
  bool isDying = false;
  final Timer goblinDeathTimer = Timer(0.4);

  @override
  FutureOr<void> onLoad() {
    _loadAnimation();
    add(RectangleHitbox.relative(parentSize: Vector2.all(280), Vector2(0.15, 0.22), position: Vector2(120, 124)));
    return super.onLoad();
  }

  @override
  void update(double dt) { 
    
    if(isDying) {
      goblinDeathTimer.resume();
      goblinDeathTimer.update(dt);
      current = GoblinState.death;
      if(goblinDeathTimer.finished){
        removeFromParent();
        goblinDeathTimer.stop();
      }
    } else {

      _goblinSpawner(dt);

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
  
  void _goblinSpawner(double dt) {
    Vector2 velocity = Vector2.zero();  
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
  }



}