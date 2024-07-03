import 'package:flame/components.dart';
import '../enemy.dart';
import 'enemy_state.dart';

class DeadState implements EnemyState2{

  @override
  void handleCollision(Enemy enemy, PositionComponent other) {
  }

  @override
  void handleCollisionEnd(Enemy enemy, PositionComponent other, ) {
  }

  @override
  void update(double dt, Enemy enemy) {
    _swordManDeath(dt, enemy);
  }

  void _swordManDeath(double dt, Enemy enemy) { 
    if(enemy.isDying == true) {
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