
import 'package:flame/components.dart';

import '../enemy.dart';

abstract class EnemyState {
  void walk(Enemy enemy){}
  void attack(Enemy enemy){}
  void die(Enemy enemy){}
  void update(double dt, Enemy enemy){}
}

abstract class EnemyState2 {
  void handleCollision(Enemy enemy, PositionComponent other){}
  void handleCollisionEnd(Enemy enemy, PositionComponent other){}
  void update(double dt, Enemy enemy){}
}