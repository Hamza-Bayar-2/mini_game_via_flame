import 'package:flame/components.dart';
import '../enemy.dart';
import 'enemy_state.dart';
import 'enemy_attacking_state.dart';
import 'enemy_dead_state.dart';

class WalkingState implements EnemyState {
  @override
  void walk(Enemy enemy) {
    enemy.current = EnemyStateEnum.run;
  }

  @override
  void attack(Enemy enemy) {
    enemy.changeState(AttackingState());
    enemy.state.attack(enemy);
  }

  @override
  void die(Enemy enemy) {
    enemy.changeState(DeadState());
    enemy.state.die(enemy);
  }

  @override
  void update(double dt, Enemy enemy) {
    _enemyMovement(dt, enemy);
  }

  void _enemyMovement(double dt, Enemy enemy) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;
    
    directionX += enemy.enemySpeed;

    if(enemy.position.x > enemy.gameRef.background.size.x && enemy.isEnemyFacingRight && enemy.isVisible) {
      enemy.deactivate();
      enemy.gameRef.newEnemyPool.addingSwordManToInactivePool(enemy);
    } else if(enemy.position.x < 0 && !enemy.isEnemyFacingRight && enemy.isVisible) {
      enemy.deactivate();
      enemy.gameRef.newEnemyPool.addingSwordManToInactivePool(enemy);
    }

    velocity = Vector2(directionX, 0);
    enemy.position.add(velocity * dt);
  }
}