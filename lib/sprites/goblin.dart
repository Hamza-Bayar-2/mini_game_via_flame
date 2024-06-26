import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

enum GoblinState {run, death, attack}

class Goblin extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks, HasVisibility{
  bool isSpawnRight;
  Vector2 enemySize;
  Goblin({
    Vector2? position,
    required this.enemySize,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight
  }) : super(position: position, size: enemySize, anchor: anchor);

  double goblinSpeed = 150;
  bool isGoblinFacingRight = true;
  bool isDying = false;
  final Timer goblinDeathTimer = Timer(0.39);
  final Timer bloodTimer = Timer(0.1);
  // I used position because the hitbox does not placed well.
  late final RectangleHitbox rectangleHitbox = RectangleHitbox.relative(parentSize: enemySize, Vector2(0.15, 0.22), position: enemySize * 0.45)..debugMode = false;
  final bool isGoblinFollowsTheArhcer = Random().nextInt(100) < 35;
  late double goblinHypotenuseSpeed = sqrt(goblinSpeed*goblinSpeed/2);

  @override
  Future<void> onLoad() async{
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
      // in kill mode when the eneny changes they will not die
      if(isDying) {
        _bloodParticles(dt);
        _goblinDeath(dt);
      } else {
        _goblinMovement(dt);
      }
    } else {
      // whitout this line the blood particles will only work for ones
      bloodTimer.reset();
    }

    super.update(dt);
  }

@override
void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  if (other is Arrow && !isDying) {
    print("goblin kill");
    isDying = true;
    FlameAudio.play("monsterDeath.mp3");
  } else if (other is ArcherPlayer) {
    deactivate();
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
  
  void _goblinMovement(double dt) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;
    double directionY = 0.0;

    if(isSpawnRight) {
      if(isGoblinFacingRight){
        flipHorizontallyAroundCenter();
        isGoblinFacingRight = false;
      }
      current = GoblinState.run;

      if(isGoblinFollowsTheArhcer && gameRef.archerPlayer.position.x < position.x) {
        directionX -= goblinHypotenuseSpeed;
        if(gameRef.archerPlayer.position.y - 20 < position.y){
          directionY -= goblinHypotenuseSpeed;
        } else {
          directionY += goblinHypotenuseSpeed;
        }
      } else {
        directionX -= goblinSpeed;
      }

      if(position.x < 0) {
        deactivate();
        // This line prevents the goblin from being deactivated as soon as it is added.
        // When the goblin wants to be used again and activate it, 
        // it will be at the border of the wall where it was deactivated, 
        // even if only for a very short time. 
        // This may cause the goblin to be deactivated before it reaches where it should be spawned.
        position = Vector2(gameRef.background.size.x, 0);
      }
    } else {
      if(!isGoblinFacingRight){
        flipHorizontallyAroundCenter();
        isGoblinFacingRight = true;
      }
      current = GoblinState.run;

      if(isGoblinFollowsTheArhcer && gameRef.archerPlayer.position.x > position.x) {
        directionX += goblinHypotenuseSpeed;
        if(gameRef.archerPlayer.position.y -20 < position.y){
          directionY -= goblinHypotenuseSpeed;
        } else {
          directionY += goblinHypotenuseSpeed;
        }
      } else {
        directionX += goblinSpeed;
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

  void _goblinDeath(double dt) {
    rectangleHitbox.collisionType = CollisionType.inactive;
    goblinDeathTimer.resume();
    goblinDeathTimer.update(dt);
    current = GoblinState.death;
    if(goblinDeathTimer.finished){
      deactivate();
      isDying = false;
      goblinDeathTimer.stop();
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