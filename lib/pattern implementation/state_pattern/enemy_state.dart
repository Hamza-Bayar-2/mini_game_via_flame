
import '../enemy.dart';

abstract class EnemyState {
  void walk(Enemy enemy){}
  void attack(Enemy enemy){}
  void die(Enemy enemy){}
  void update(double dt, Enemy enemy){}
}
