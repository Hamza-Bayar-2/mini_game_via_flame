import 'package:flame/components.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';
import '../../sprites/archer.dart';
import '../enemy.dart';
import 'enemy_state.dart';

class WalkingState implements EnemyState2 {

  @override
  void handleCollision(Enemy enemy, PositionComponent other, ) {
    if(other is Arrow) {
      enemy.die();
    } else if(other is ArcherPlayer) {
      enemy.attack();
    }
  }

  @override
  void handleCollisionEnd(Enemy enemy, PositionComponent other, ) {
  }

  @override
  void update(double dt, Enemy enemy) {
    _enemyMovement(dt, enemy);
    _enemyDirection(enemy);
  }

  void _enemyMovement(double dt, Enemy enemy) {
    Vector2 velocity = Vector2.zero();  
    double directionX = 0.0;
    
    directionX += enemy.enemySpeed;

    if(enemy.position.x > enemy.gameRef.background.size.x && enemy.isEnemyFacingRight && enemy.isVisible) {
      enemy.deactivate();
    } else if(enemy.position.x < 0 && !enemy.isEnemyFacingRight && enemy.isVisible) {
      enemy.deactivate();
    }

    velocity = Vector2(directionX, 0);
    enemy.position.add(velocity * dt);
  }

  void _enemyDirection(Enemy enemy) {
    if(enemy.isSpawnRight && enemy.isEnemyFacingRight) {
      if(enemy.enemySpeed > 0) {
        enemy.enemySpeed *= -1;
      }
      enemy.flipHorizontallyAroundCenter();
      enemy.isEnemyFacingRight = false;
    } else if(!enemy.isSpawnRight && !enemy.isEnemyFacingRight) {
      if(enemy.enemySpeed < 0) {
        enemy.enemySpeed *= -1;
      }
      enemy.flipHorizontallyAroundCenter();
      enemy.isEnemyFacingRight = true;
    }
  }
}