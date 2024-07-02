import '../enemy.dart';
import 'enemy_direction_strategy.dart';

class DirectionRight implements DirectionStrategy {

  @override
  void direction(Enemy enemy) {
    if(!enemy.isEnemyFacingRight) {
      enemy.isEnemyFacingRight = true;
      enemy.flipHorizontallyAroundCenter();
      enemy.enemySpeed *= -1;
    }
  }
}
