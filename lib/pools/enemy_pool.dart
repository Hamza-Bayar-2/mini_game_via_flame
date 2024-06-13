
import 'package:flame/components.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/flyingEye.dart';
import 'package:mini_game_via_flame/sprites/goblin.dart';
import 'package:mini_game_via_flame/sprites/mushroom.dart';
import 'package:mini_game_via_flame/sprites/skeleton.dart';

class EnemyPool extends Component with HasGameRef<MiniGame> {
  final List<Goblin> _goblinPool = [];
  final List<Mushroom> _mushroomPool = [];
  final List<FlyingEye> _flyinEyePool = [];
  final List<Skeleton> _skeletonPool = [];

  Goblin goblinAcquire(bool isSpawnRight, Vector2 enemySize) {
    for (var enemy in _goblinPool) {
      // if there is an unused enemy it will be returned
      if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      } else if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      }
    }
    // but in case no enemy is available a new enemy will be created
    // then it will be added to the pool and returned
    final newGoblin = Goblin(enemySize: enemySize, isSpawnRight: isSpawnRight);
    _goblinPool.add(newGoblin);
    return newGoblin;
  }

  Mushroom mushroomAcquire(bool isSpawnRight, Vector2 enemySize) {
    for (var enemy in _mushroomPool) {
      if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      } else if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      }
    }
    final newMushroom = Mushroom(enemySize: enemySize, isSpawnRight: isSpawnRight);
    _mushroomPool.add(newMushroom);
    return newMushroom;
  }

    FlyingEye flyingEyeAcquire(bool isSpawnRight, Vector2 enemySize) {
    for (var enemy in _flyinEyePool) {
      if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      } else if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      }
    }
    final newFlyingEye = FlyingEye(enemySize: enemySize, isSpawnRight: isSpawnRight);
    _flyinEyePool.add(newFlyingEye);
    return newFlyingEye;
  }

  Skeleton skeletonAcquire(bool isSpawnRight, Vector2 enemySize) {
    for (var enemy in _skeletonPool) {
      if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      } else if (!enemy.isVisible && enemy.isSpawnRight == isSpawnRight) {
        return enemy;
      }
    }
    final newSkeleton = Skeleton(enemySize: enemySize, isSpawnRight: isSpawnRight);
    _skeletonPool.add(newSkeleton);
    return newSkeleton;
  }
  
  get goblinPoolLength => _goblinPool.length;
  get mushroomPoolLength => _mushroomPool.length;
  get flyingEyePoolLength => _flyinEyePool.length;
  get skeletonPoolLength => _skeletonPool.length;
}