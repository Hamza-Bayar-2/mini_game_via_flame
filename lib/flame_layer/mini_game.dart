import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:mini_game_via_flame/blocs/taping_down/taping_down_bloc.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';
import 'dart:async';


class MiniGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks{
  late final Sprite background;
  final TapingDownBloc tapingDownBloc;
  late final ArcherPlayer archerPlayer;
  // 0.72 seconds is the frame amount of the attack animation multiplies by step time (6 * 0.12)
  // The purpose of this timer is to ensure that arrows are released at the right time 
  // in the archer's attack animation. 
  final Timer countdownAndRepeat = Timer(0.72);
  
  MiniGame({required this.tapingDownBloc});

  @override
  Future<void> onLoad() async{
    await FlameAudio.audioCache.load('running.mp3');
    await images.loadAllImages();
    background = Sprite(images.fromCache("background.png"));
    // add(SpriteComponent(sprite: background, size: size));
    archerPlayer = ArcherPlayer();

    add(FlameBlocProvider.value(value: tapingDownBloc, children: [archerPlayer]));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    countdownAndRepeat.update(dt);

    if(tapingDownBloc.state.isTapingDown && tapingDownBloc.state.archerHelth > 0) {
      countdownAndRepeat.resume();
      // when the time is up the arrow is released
      if(countdownAndRepeat.finished) {
        add(_arrowCreater());
        countdownAndRepeat.start();
      }
    } else {
      countdownAndRepeat.stop();
    } 
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    print("tapdown");
    // by this event the isTapingDown bool variable is changing to true
    tapingDownBloc.add(TapingEvent());
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print("tapup");
    tapingDownBloc.add(NotTapingEvent());
    super.onTapUp(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    print("tapDrag");
    tapingDownBloc.add(TapingEvent());
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    print("tapDragEnd");
    tapingDownBloc.add(NotTapingEvent());
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    print("tapDragCancel");
    tapingDownBloc.add(NotTapingEvent());
    super.onDragCancel(event);
  }

    // this method creates arrow everytime it called
    Arrow _arrowCreater() {
    return Arrow(
      position: archerPlayer.position + (tapingDownBloc.state.isPlayerFacingRight ? Vector2(-80, -18) : Vector2(80, -18)),
      size: Vector2(48, 10),
      animation: _arrowAnimation(),
      anchor: Anchor.center
    );
    }

    SpriteAnimation _arrowAnimation() {
    return SpriteAnimation.fromFrameData(
      images.fromCache("Archer/Arrow/Move.png"),
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.07,
        textureSize: Vector2(24, 5),
      ),
    );
  }
}
