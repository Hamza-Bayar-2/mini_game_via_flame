import '../enemy.dart';
import 'enemy_direction_strategy.dart';

class DirectionLeft implements DirectionStrategy {

  @override
  void direction(Enemy enemy) {
    if(enemy.isEnemyFacingRight) {
      enemy.isEnemyFacingRight = false;
      enemy.flipHorizontallyAroundCenter();
      enemy.enemySpeed *= -1;
    }
  }
}

