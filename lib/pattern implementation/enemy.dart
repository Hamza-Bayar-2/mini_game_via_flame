import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/pattern%20implementation/state_pattern/enemy_walking_state.dart';
import 'package:mini_game_via_flame/pattern%20implementation/strategy_pattern/enemy_direction_strategy.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';
import 'state_pattern/enemy_state.dart';

enum EnemyStateEnum {run, death, attack}

class Enemy extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks, HasVisibility{
  EnemyState state;
  DirectionStrategy directionStrategy;
  int enemySpeed;
  final String sourceFile;
  final Vector2 textureSize;
  final int runFrameAmount;
  final int deathFrameAmount;
  final int attackFrameAmount;
  late final RectangleHitbox swordHitbox;
  late final RectangleHitbox swordManHitbox;
  bool isEnemyFacingRight = true;
  bool isDying = false;
  double stepTimeRun = 0.1;
  double stepTimeDeath = 0.1;
  double stepTimeAttack = 0.2;
  late Timer deathTimer = Timer(stepTimeDeath * deathFrameAmount);

  Enemy({
    required this.state,
    required this.directionStrategy,
    required this.enemySpeed,
    required Vector2 position,
    required Vector2 size,
    required this.sourceFile,
    required this.textureSize, 
    required this.runFrameAmount,
    required this.deathFrameAmount,
    required this.attackFrameAmount
  }) : super(position: position, anchor: Anchor.center, size: size);

  void changeState(EnemyState newState) {
    state = newState;
  }

  void setDirectionStrategy(DirectionStrategy strategy) {
    directionStrategy = strategy;
  }

  void walk() {
    directionStrategy.direction(this);
    state.walk(this);
  }

  void attack() {
    directionStrategy.direction(this);
    state.attack(this);
  }

  void die() {  
    directionStrategy.direction(this);
    state.die(this);
  }

  @override
  FutureOr<void> onLoad() {
    swordHitbox = RectangleHitbox.relative(
      parentSize: size, 
      Vector2(0.4, 0.4), 
      anchor: Anchor.center, 
      position: Vector2(size.x * 0.8, size.y * 0.4)
    )..debugMode = false;

    swordManHitbox = RectangleHitbox.relative(
      parentSize: size, 
      Vector2(0.3, 0.3), 
      anchor: Anchor.center, 
    )..debugMode = false;

    swordHitbox.collisionType = CollisionType.inactive;
    swordManHitbox.collisionType = CollisionType.active;
    addAll({swordHitbox, swordManHitbox});
    _loadAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(gameRef.miniGameBloc.state.isArcherDead || gameRef.miniGameBloc.state.isTheGameReset) {
      deactivate();
    }

    state.update(dt, this);
    _swordManDeath(dt);
    _isTheEnemyWithinAttackRange();
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is Arrow) {
      isDying = true;
      die();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _loadAnimation() {
    final runAnimation = _spriteAnimation(enemyState: "Run", frameAmount: runFrameAmount, stepTime: stepTimeRun);
    final deathAnimation = _spriteAnimation(enemyState: "Death", frameAmount: deathFrameAmount, stepTime: stepTimeDeath);
    final attackAnimation = _spriteAnimation(enemyState: "Attack", frameAmount: attackFrameAmount, stepTime: stepTimeAttack);

    animations = {
      EnemyStateEnum.run: runAnimation,
      EnemyStateEnum.death: deathAnimation,
      EnemyStateEnum.attack: attackAnimation,
    };
  }

  SpriteAnimation _spriteAnimation({required String enemyState, required int frameAmount, required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("$sourceFile/$enemyState.png"),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _isTheEnemyWithinAttackRange() {
    if((gameRef.archerPlayer.position.x - position.x).abs() < 120
    && (gameRef.archerPlayer.position.y - position.y).abs() < 60) {
      attack();
    } else {
      walk();
    }
  }

  void _swordManDeath(double dt) {
    if(isDying == true) {
      swordManHitbox.collisionType = CollisionType.inactive;
      deathTimer.resume();
      deathTimer.update(dt);
      if(deathTimer.finished){
        deactivate();
        deathTimer.stop();
        isDying = false;
      }
    }
  }

  void activate() {
    isVisible = true;
    swordManHitbox.collisionType = CollisionType.active;
    changeState(WalkingState());
    walk();
  } 
  
  void deactivate() {
    swordHitbox.collisionType = CollisionType.inactive;
    swordManHitbox.collisionType = CollisionType.inactive;
    gameRef.newEnemyPool.addingSwordManToInactivePool(this);
    isVisible = false;
    die();
  }
}
