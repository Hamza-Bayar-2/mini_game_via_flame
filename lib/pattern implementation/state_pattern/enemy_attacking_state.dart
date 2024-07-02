import '../enemy.dart';
import 'enemy_state.dart';
import 'enemy_dead_state.dart';
import 'enemy_walking_state.dart';

class AttackingState implements EnemyState {
  

  @override
  void walk(Enemy enemy) {
    enemy.changeState(WalkingState());
    enemy.state.walk(enemy);
  }

  @override
  void attack(Enemy enemy) {
    enemy.current = EnemyStateEnum.attack;
  }

  @override
  void die(Enemy enemy) {
    enemy.changeState(DeadState());
    enemy.state.die(enemy);
  }
  
  @override
  void update(double dt, Enemy enemy) {

  }
}