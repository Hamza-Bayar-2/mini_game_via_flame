import 'package:flame/components.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import '../../sprites/arrow.dart';
import '../enemy.dart';
import 'enemy_state.dart';

class AttackingState implements EnemyState2{
  
  @override
  void handleCollision(Enemy enemy, PositionComponent other) {
    if(other is Arrow) {
      enemy.die();
    } 
  }

  @override
  void handleCollisionEnd(Enemy enemy, PositionComponent other) {
    if(other is ArcherPlayer) {
      enemy.walk();
    }
  }

  @override
  void update(double dt, Enemy enemy) {
    _enemyAttackinSide(enemy);
  }

  void _enemyAttackinSide(Enemy enemy) {
    if(!enemy.isEnemyFacingRight && _isTheArcherOnTheRightOfTheEnemy(enemy)) {
      enemy.flipHorizontallyAroundCenter();
      enemy.isEnemyFacingRight = true;
    } else if(enemy.isEnemyFacingRight && !_isTheArcherOnTheRightOfTheEnemy(enemy)) {
      enemy.flipHorizontallyAroundCenter();
      enemy.isEnemyFacingRight = false;
    }
  }

  bool _isTheArcherOnTheRightOfTheEnemy(Enemy enemy) {
    if(enemy.gameRef.archerPlayer.position.x - enemy.position.x > 0) {
      return true;
    } else {
      return false;
    }
  }

}