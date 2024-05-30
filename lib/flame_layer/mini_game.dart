import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
  bool isTapingDown = false;

class MiniGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks{

  @override
  Future<void> onLoad() async{
    await FlameAudio.audioCache.load('running.mp3');
    await images.loadAllImages();

    add(ArcherPlayer());
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    print("tapdown");
    isTapingDown = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print("tapup");
    isTapingDown = false;
    super.onTapUp(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    print("tapDrag");
    isTapingDown = true;
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    print("tapDragEnd");
    isTapingDown = false;
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    print("tapDragCancel");
    isTapingDown = false;
    super.onDragCancel(event);
  }
}
