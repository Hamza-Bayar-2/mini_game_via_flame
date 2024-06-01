import 'package:flame/components.dart';
import 'package:mini_game_via_flame/flame_layer/mini_game.dart';



class Arrow extends SpriteAnimationComponent with HasGameRef<MiniGame>{
  Arrow({
    SpriteAnimation? animation,
    Vector2? position,
    Vector2? size,
    Anchor? anchor
  }) : super(animation: animation, position: position, size: size, anchor: anchor);

  final double _arrowSpeed = 500;
  Vector2 velocity = Vector2.zero();  
  bool isArrowFacingRight = true;
  // the reason why I used variable instead of using it directly inside the "if"
  // because when I do it like that the arrow will change direction 
  // according to the archer even after leaving the bow
  late bool isArcherFacingRight = gameRef.tapingDownBloc.state.isPlayerFacingRight;

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

    /// ok yok edilince oyun çöküyorrrrrrrrrrrrrrr
    if(position.x < 0 || position.x > gameRef.size.x) {
      removeFromParent(); // burasi hataaaaali olabilirrrrr
    }
    super.update(dt);
  }
}












// class Arrow extends SpriteAnimationGroupComponent with HasGameRef<MiniGame>{
//   Arrow({
//     SpriteAnimation? spriteAnimation,
//     Vector2? position,
//     Vector2? size,
//   }) : super(current: spriteAnimation, position: position, size: size,);

//   final double _arrowSpeed = 500;
//   Vector2 velocity = Vector2.zero();  


//   @override
//   void update(double dt) {
//     double directionX = 0.0;
//     // this for set the arrow direction (right or left)
//     if(gameRef.tapingDownBloc.state.isPlayerFacingRight) {
//       directionX += _arrowSpeed;
//     } else {
//       directionX -= _arrowSpeed;
//     }

//     velocity = Vector2(directionX, 0);
//     position += velocity * dt/100;

//     if(position.x < 0 || position.x > 2500) {
//       remove(Arrow()); // burasi hataaaaali olabilirrrrr
//     }
//     super.update(dt);
//   }
// }