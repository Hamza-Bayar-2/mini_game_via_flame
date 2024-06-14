import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum MushroomState {run, death, attack}

class Mushroom extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks, HasVisibility{
  bool isSpawnRight;
  Vector2 enemySize;
  Mushroom({
    Vector2? position,
    required this.enemySize,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: enemySize, anchor: anchor);

  double mushroomSpeed = 170;
  bool isMushroomFacingRight = true;
  bool isDying = false;
  final Timer mushroomDeathTimer = Timer(0.39);
  final Timer bloodTimer = Timer(0.1);
  late final rectangleHitbox = RectangleHitbox.relative(parentSize: enemySize, Vector2(0.15, 0.25), position: enemySize * 0.42)..debugMode = false;
  final bool isMushroomFollowsTheArhcer = Random().nextInt(100) < 30;
  late double mushroomHypotenuseSpeed = sqrt(mushroomSpeed*mushroomSpeed/2);

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
      if(isDying || (gameRef.miniGameBloc.state.gameStage != 2 && gameRef.miniGameBloc.state.gameMode == 0)) {
        _bloodParticles(dt);
        _mushroomDeath(dt);
      } else {
        _mushroomMovement(dt);
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
      FlameAudio.play("mushroomDeath.mp3");
    } 
    else if (other is ArcherPlayer) {
      deactivate();
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

  void _mushroomMovement(double dt) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;
    double directionY = 0.0;

    if(isSpawnRight) {
      if(isMushroomFacingRight){
        flipHorizontallyAroundCenter();
        isMushroomFacingRight = false;
      }
      current = MushroomState.run;

      if(isMushroomFollowsTheArhcer && gameRef.archerPlayer.position.x < position.x) {
        directionX -= mushroomHypotenuseSpeed;
        if(gameRef.archerPlayer.position.y < position.y){
          directionY -= mushroomHypotenuseSpeed;
        } else {
          directionY += mushroomHypotenuseSpeed;
        }
      } else {
        directionX -= mushroomSpeed;
      }

      if(position.x < 0) {
        deactivate();
        position = Vector2(gameRef.background.size.x, 0);
      }
    } else {
      if(!isMushroomFacingRight){
        flipHorizontallyAroundCenter();
        isMushroomFacingRight = true;
      }
      current = MushroomState.run;

      if(isMushroomFollowsTheArhcer && gameRef.archerPlayer.position.x > position.x) {
        directionX += mushroomHypotenuseSpeed;
        if(gameRef.archerPlayer.position.y < position.y){
          directionY -= mushroomHypotenuseSpeed;
        } else {
          directionY += mushroomHypotenuseSpeed;
        }
      } else {
        directionX += mushroomSpeed;
      }

      if(position.x > gameRef.background.size.x) {
        deactivate();
        position = Vector2(0, 0);
      }
    }

    velocity = Vector2(directionX, directionY);
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

  void _mushroomDeath(double dt) {
    rectangleHitbox.collisionType = CollisionType.inactive;
    mushroomDeathTimer.resume();
    mushroomDeathTimer.update(dt);
    current = MushroomState.death;
    if(mushroomDeathTimer.finished){
      deactivate();
      isDying = false;
      mushroomDeathTimer.stop();
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