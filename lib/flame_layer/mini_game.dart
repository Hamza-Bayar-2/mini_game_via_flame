import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';

class MiniGame extends FlameGame with HasKeyboardHandlerComponents{

  @override
  Future<void> onLoad() async{
    await images.loadAllImages();
    add(ArcherPlayer());
    return super.onLoad();
  }
}