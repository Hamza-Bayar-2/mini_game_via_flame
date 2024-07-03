import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/pattern%20implementation/state_pattern/enemy_attacking_state.dart';
import 'package:mini_game_via_flame/pattern%20implementation/state_pattern/enemy_dead_state.dart';
import 'package:mini_game_via_flame/pattern%20implementation/state_pattern/enemy_walking_state.dart';
import 'state_pattern/enemy_state.dart';

enum EnemyStateEnum {run, death, attack}

class Enemy extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>, CollisionCallbacks, HasVisibility{
  EnemyState2 state2;
  // DirectionStrategy directionStrategy;
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
  bool isSpawnRight;
  late Timer deathTimer = Timer(stepTimeDeath * deathFrameAmount);

  Enemy({
    required this.state2,
    // required this.directionStrategy,
    required this.enemySpeed,
    required Vector2 position,
    required Vector2 size,
    required this.sourceFile,
    required this.textureSize, 
    required this.runFrameAmount,
    required this.deathFrameAmount,
    required this.attackFrameAmount,
    required this.isSpawnRight
  }) : super(position: position, anchor: Anchor.center, size: size);

  void changeState(EnemyState2 newState) {
    state2 = newState;
  }

  // void setDirectionStrategy(DirectionStrategy strategy) {
  //   directionStrategy = strategy;
  // }

  void walk() {
    changeState(WalkingState());
    current = EnemyStateEnum.run;
  }

  void attack() {
    changeState(AttackingState());
    current = EnemyStateEnum.attack;
  }

  void die() {  
    changeState(DeadState());
    current = EnemyStateEnum.death;
    swordManHitbox.collisionType = CollisionType.inactive;
    isDying = true;
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
    addAll({swordHitbox, swordManHitbox});
    _loadAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(gameRef.miniGameBloc.state.isArcherDead || gameRef.miniGameBloc.state.isTheGameReset) {
      deactivate();
    }

    state2.update(dt, this);
    super.update(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    state2.handleCollision(this, other);
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    state2.handleCollisionEnd(this, other);
    super.onCollisionEnd(other);
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


  void activate() {
    isVisible = true;
    swordManHitbox.collisionType = CollisionType.active;
    walk();
  }
  
  void deactivate() {
    swordHitbox.collisionType = CollisionType.inactive;
    swordManHitbox.collisionType = CollisionType.inactive;
    gameRef.newEnemyPool.movingEnemyFromActiveToInactivePool(this);
    isVisible = false;
  }
}
