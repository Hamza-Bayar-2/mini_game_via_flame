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
    // _isTheEnemyWithinAttackRange(enemy);
  }

  // void _isTheEnemyWithinAttackRange(Enemy enemy) {
  //   if((enemy.gameRef.archerPlayer.position.x - enemy.position.x).abs() < 120
  //   && (enemy.gameRef.archerPlayer.position.y - enemy.position.y).abs() < 60) {
  //     enemy.attack();
  //   } else {
  //     enemy.walk();
  //   }
  // }
}