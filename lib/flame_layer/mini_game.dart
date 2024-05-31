import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:mini_game_via_flame/blocs/taping_down/taping_down_bloc.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
  //bool isTapingDown = false; /// do not forgat to remove its

class MiniGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks{
  late final Sprite background;
  final TapingDownBloc tapingDownBloc;
  
  MiniGame({required this.tapingDownBloc});

  @override
  Future<void> onLoad() async{
    await FlameAudio.audioCache.load('running.mp3');
    await images.loadAllImages();
    background = Sprite(images.fromCache("background.png"));
    add(SpriteComponent(sprite: background, size: size));

    add(FlameBlocProvider.value(value: tapingDownBloc, children: [ArcherPlayer()]));
    //add(ArcherPlayer());
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    print("tapdown");
    // by this event the isTapingDown bool variable is changing to true
    tapingDownBloc.add(TapingDown());
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print("tapup");
    tapingDownBloc.add(NotTapingDown());
    super.onTapUp(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    print("tapDrag");
    tapingDownBloc.add(TapingDown());
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    print("tapDragEnd");
    tapingDownBloc.add(NotTapingDown());
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    print("tapDragCancel");
    tapingDownBloc.add(NotTapingDown());
    super.onDragCancel(event);
  }
}
