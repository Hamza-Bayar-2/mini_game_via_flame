import 'package:flame/components.dart';
import 'package:mini_game_via_flame/pattern%20implementation/enemy.dart';
import 'package:mini_game_via_flame/pattern%20implementation/strategy_pattern/enemy_direction_left_strategy.dart';
import '../flame_layer/mini_game.dart';
import '../pattern implementation/state_pattern/enemy_walking_state.dart';
import '../pattern implementation/strategy_pattern/enemy_direction_right_strategy.dart';

class NewEnemyPool extends Component with HasGameRef<MiniGame> {
  final List<Enemy> _swordManInactivePool = [];
  late Enemy swordMan;

  Enemy swordManAcquire(bool isSpawnRight) {
    if(_swordManInactivePool.isNotEmpty) {
      swordMan = _swordManInactivePool.removeLast();
      swordMan.activate();
    } else {
      swordMan = Enemy(
      state: WalkingState(), 
      directionStrategy: DirectionRight(),
      enemySpeed: 150, 
      position: Vector2.all(0),
      size: Vector2.all(250),
      sourceFile: "Sword Man",
      textureSize: Vector2.all(135),
      runFrameAmount: 6,
      deathFrameAmount: 9,
      attackFrameAmount: 5
      );
      swordMan.walk();
    }

    if(isSpawnRight && swordMan.isEnemyFacingRight) {
      swordMan.setDirectionStrategy(DirectionLeft());
      swordMan.directionStrategy.direction(swordMan);
    } else if(!isSpawnRight && !swordMan.isEnemyFacingRight) {
      swordMan.setDirectionStrategy(DirectionRight());
      swordMan.directionStrategy.direction(swordMan);
    }

    print(_swordManInactivePool.length);
    return swordMan;
  }

  void addingSwordManToInactivePool(Enemy swordMan) {
    _swordManInactivePool.add(swordMan);
  }


}
