import 'package:flame/components.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';

class ArrowPool extends Component with HasGameRef<MiniGame> {
  final List<Arrow> _pool = [];

  Arrow acquire() {
    for (var arrow in _pool) {
      // if there is an unused arrow it will be returned
      if (!arrow.isVisible) {
        return arrow;
      }
    }
    // but in case no arrow is available a new arrow will be created
    // then it will be added to the pool and returned
    final newArrow = _arrowCreater();
    _pool.add(newArrow);
    return newArrow;
  }

  get poolLength => _pool.length;
  
  Arrow _arrowCreater() {
    return Arrow(
      position: gameRef.archerPlayer.position + Vector2(0, -gameRef.background.size.y * 0.03),
      // 0.12 and 0.025 are the ratio of the arrow
      size: Vector2(gameRef.background.size.x * gameRef.arrowScale * 0.12, gameRef.background.size.y * gameRef.arrowScale * 0.025),
      animation: _arrowAnimation(),
      anchor: Anchor.center
    )..debugMode = false;
  }

  SpriteAnimation _arrowAnimation() {
    return SpriteAnimation.fromFrameData(
      gameRef.images.fromCache("Archer/Arrow/Move.png"),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.07,
        textureSize: Vector2(24, 5),
      ),
    );
  }
}