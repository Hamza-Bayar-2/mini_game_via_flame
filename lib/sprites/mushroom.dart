import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum MushroomState {run, death, attack}

class Mushroom extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks{
  bool isSpawnRight;
  Mushroom({
    Vector2? position,
    Vector2? size,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: size, anchor: anchor);

  double mushroomSpeed = 170;
  bool isMushroomFacingRight = true;
  bool isDying = false;
  final Timer mushroomDeathTimer = Timer(0.39);
  final rectangleHitbox = RectangleHitbox.relative(parentSize: Vector2.all(280), Vector2(0.15, 0.25), position: Vector2(120, 115));

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

    if(isDying || gameRef.miniGameBloc.state.isArcherDead || gameRef.miniGameBloc.state.gameStage != 2) {
      rectangleHitbox.removeFromParent();
      mushroomDeathTimer.resume();
      mushroomDeathTimer.update(dt);
      current = MushroomState.death;
      if(mushroomDeathTimer.finished){
        removeFromParent();
        mushroomDeathTimer.stop();
      }
    } else {

      _mushroomSpawner(dt);

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
    final runAnimation = _spriteAnimation(mushroomState: "Run", frameAmount: 8, stepTime: time);
    final deathAnimation = _spriteAnimation(mushroomState: "Death", frameAmount: 4, stepTime: time);
    final attackAnimation = _spriteAnimation(mushroomState: "Attack", frameAmount: 8, stepTime: time);

    animations = {
      MushroomState.run: runAnimation,
      MushroomState.death: deathAnimation,
      MushroomState.attack: attackAnimation,
    };
  }

  SpriteAnimation _spriteAnimation({required String mushroomState, required int frameAmount, required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Enemies/Mushroom/$mushroomState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(150),
      ),
    );
  }

  void _mushroomSpawner(double dt) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;

    if(isSpawnRight) {
      directionX -= mushroomSpeed;  
      if(isMushroomFacingRight){
        flipHorizontallyAroundCenter();
        isMushroomFacingRight = false;
      }
      current = MushroomState.run;

      if(position.x < 0) {
      removeFromParent(); 
    }
    } else {
      directionX += mushroomSpeed;
      if(!isMushroomFacingRight){
        flipHorizontallyAroundCenter();
        isMushroomFacingRight = true;
      }
      current = MushroomState.run;

      if(position.x > gameRef.size.x) {
        removeFromParent(); 
      }
    }

    velocity = Vector2(directionX, 0);
    position += velocity * dt;
  }
}