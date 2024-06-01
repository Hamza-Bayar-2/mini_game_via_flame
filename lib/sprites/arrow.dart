import 'package:flame/components.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';



class Arrow extends SpriteAnimationComponent with HasGameRef<MiniGame>{
  Arrow({
    SpriteAnimation? animation,
    Vector2? position,
    Vector2? size,
    Anchor? anchor
  }) : super(animation: animation, position: position, size: size, anchor: anchor);

  final double _arrowSpeed = 600;
  Vector2 velocity = Vector2.zero();  
  bool isArrowFacingRight = true;

  // the reason why I used variable instead of using it directly inside the "if"
  // because when I do it like that the arrow will change direction 
  // according to the archer even after leaving the bow
  late bool isArcherFacingRight = gameRef.miniGameBloc.state.isPlayerFacingRight;

  @override
  void update(double dt) {
    double directionX = 0.0;
    // this for set the arrow direction (right or left)
    if(isArcherFacingRight) {
      directionX += _arrowSpeed;
      if(!isArrowFacingRight) {
        flipHorizontallyAroundCenter();
        isArrowFacingRight = true;
      }
    } else {
      directionX -= _arrowSpeed;
      if(isArrowFacingRight){
        flipHorizontallyAroundCenter();
        isArrowFacingRight = false;
      }
    }

    velocity = Vector2(directionX, 0);
    position += velocity * dt;

    if(position.x < 0 || position.x > gameRef.size.x) {
      removeFromParent(); 
    }
    super.update(dt);
  }
}