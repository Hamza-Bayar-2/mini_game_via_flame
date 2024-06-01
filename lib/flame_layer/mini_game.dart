import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:mini_game_via_flame/blocs/mini_game/mini_game_bloc.dart';
import 'package:mini_game_via_flame/sprites/archer.dart';
import 'package:mini_game_via_flame/sprites/arrow.dart';
import 'dart:async';
import 'package:mini_game_via_flame/sprites/goblin.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';

class MiniGame extends FlameGame with HasKeyboardHandlerComponents, TapCallbacks, DragCallbacks{
  final MiniGameBloc miniGameBloc;
  MiniGame({required this.miniGameBloc});
  late final Sprite background;
  late final ArcherPlayer archerPlayer;
  // 0.72 seconds is the frame amount of the attack animation multiplies by step time (6 * 0.12)
  // The purpose of this timer is to ensure that arrows are released at the right time 
  // in the archer's attack animation. 
  final Timer countdownAndRepeat = Timer(0.72);
  late Bgm backgroundMusic = FlameAudio.bgmFactory(audioCache: FlameAudio.audioCache); 
  final double goblinSpawnPeriod = 3;
  

  @override
  Future<void> onLoad() async{
    await FlameAudio.audioCache.loadAll(['running.mp3', 'arrow.mp3', 'death.mp3', 'hurt.mp3', 'monsterDeath.mp3', 'bgm.mp3']);
    await images.loadAllImages();
    background = Sprite(images.fromCache("background.png"));
    archerPlayer = ArcherPlayer();
    add(SpriteComponent(sprite: background, size: size));
    add(FlameBlocProvider.value(value: miniGameBloc, children: [archerPlayer]));

    add(
      SpawnComponent(
        factory: (index) {
          return Goblin(isSpawnRight: true, size: Vector2.all(200));
        },
        period: goblinSpawnPeriod,
        area: Rectangle.fromLTWH(size.x, 0, 0, size.y),
      ),
    );

    add(_goblinCreater(true, Vector2.all(250), size.x));
    add(_goblinCreater(false, Vector2.all(250), 0));

    // add(Goblin(isSpawnRight: true, position: Vector2.all(400), size: Vector2.all(200)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(miniGameBloc.state.isTapingDown && !miniGameBloc.state.isArcherDead) {
      countdownAndRepeat.update(dt);
      countdownAndRepeat.resume();
      // when the time is up the arrow is released
      if(countdownAndRepeat.finished) {
        add(_arrowCreater());
        FlameAudio.play("arrow.mp3");
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
    if(!backgroundMusic.isPlaying) {
      backgroundMusic.play("bgm.mp3", volume: 0.1);
    }
    // by this event the isTapingDown bool variable is changing to true
    miniGameBloc.add(TapingEvent());
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print("tapup");
    miniGameBloc.add(NotTapingEvent());
    super.onTapUp(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    print("tapDrag");
    miniGameBloc.add(TapingEvent());
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    print("tapDragEnd");
    miniGameBloc.add(NotTapingEvent());
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    print("tapDragCancel");
    miniGameBloc.add(NotTapingEvent());
    super.onDragCancel(event);
  }

    // this method creates arrow everytime it called
  Arrow _arrowCreater() {
    return Arrow(
      position: archerPlayer.position + (miniGameBloc.state.isPlayerFacingRight ? Vector2(-80, -18) : Vector2(80, -18)),
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

  SpawnComponent _goblinCreater(bool isSpawnRight, Vector2 vector2, double positionX) {
    return SpawnComponent(
        factory: (index) {
          return Goblin(isSpawnRight: isSpawnRight, size: vector2);
        },
        period: goblinSpawnPeriod,
        area: Rectangle.fromLTWH(positionX, 0, 0, size.y),
      );
  }

}
