import 'package:flame/components.dart';
import 'package:mini_game_via_flame/pattern%20implementation/enemy.dart';
import '../flame_layer/mini_game.dart';
import '../pattern implementation/state_pattern/enemy_walking_state.dart';

class NewEnemyPool extends Component with HasGameRef<MiniGame> {
  final List<Enemy> _swordManInactivePool = [];
  final List<Enemy> _swordManActivePool = [];
  late Enemy swordMan;

  Enemy swordManAcquire(bool isSpawnRight) {
    if(_swordManInactivePool.isNotEmpty) {
      swordMan = _swordManInactivePool.removeLast();
      swordMan.isSpawnRight = isSpawnRight;
      swordMan.activate();
    } else {
      swordMan = Enemy(
      state2: WalkingState(), 
      // directionStrategy: DirectionRight(),
      enemySpeed: 150, 
      position: Vector2.all(0),
      size: Vector2.all(250),
      sourceFile: "Sword Man",
      textureSize: Vector2.all(135),
      runFrameAmount: 6,
      deathFrameAmount: 9,
      attackFrameAmount: 5,
      isSpawnRight: isSpawnRight
      );
      swordMan.walk();
    }

    // if(isSpawnRight && swordMan.isEnemyFacingRight) {
    //   swordMan.setDirectionStrategy(DirectionLeft());
    //   swordMan.directionStrategy.direction(swordMan);
    // } else if(!isSpawnRight && !swordMan.isEnemyFacingRight) {
    //   swordMan.setDirectionStrategy(DirectionRight());
    //   swordMan.directionStrategy.direction(swordMan);
    // }

    print("aktif    ${_swordManActivePool.length}");
    print("in aktif ${_swordManInactivePool.length}\n");
    _swordManActivePool.add(swordMan);
    return swordMan;
  }

  void movingEnemyFromActiveToInactivePool(Enemy swordMan) {
    if(_swordManActivePool.remove(swordMan)) {
      _swordManInactivePool.add(swordMan);
    }
  }


}
