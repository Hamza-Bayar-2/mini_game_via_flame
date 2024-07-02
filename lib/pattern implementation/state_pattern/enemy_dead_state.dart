import 'package:flame/collisions.dart';
import '../enemy.dart';
import 'enemy_state.dart';

class DeadState implements EnemyState {
  @override
  void walk(Enemy enemy) {
    // Can not walk while dead
  }

  @override
  void attack(Enemy enemy) {
    // Can not attack while dead
  }

  @override
  void die(Enemy enemy) {
    enemy.current = EnemyStateEnum.death;
  }
  
  @override
  void update(double dt, Enemy enemy) {
    _swordManDeath(dt, enemy);
  }

  void _swordManDeath(double dt, Enemy enemy) { 
    if(enemy.isDying == true) {
      enemy.swordManHitbox.collisionType = CollisionType.inactive;
      enemy.deathTimer.resume();
      enemy.deathTimer.update(dt);
      if(enemy.deathTimer.finished){
        enemy.deactivate();
        enemy.deathTimer.stop();
        enemy.isDying = false;
      }
    }
  }
}