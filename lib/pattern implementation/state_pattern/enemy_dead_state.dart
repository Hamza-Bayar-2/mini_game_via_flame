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
  }
}