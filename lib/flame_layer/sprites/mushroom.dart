import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:the_hunter/constants/audio_constants.dart';
import 'package:the_hunter/constants/image_constants.dart';
import 'package:the_hunter/flame_layer/mini_game.dart';
import 'package:the_hunter/flame_layer/player/player_component.dart';
import 'package:the_hunter/flame_layer/sprites/arrow.dart';

enum MushroomState { run, death, attack }

class Mushroom extends SpriteAnimationGroupComponent
    with HasGameReference<MiniGame>, CollisionCallbacks, HasVisibility {
  bool isSpawnRight;
  Vector2 enemySize;
  Mushroom({
    Vector2? position,
    required this.enemySize,
    Anchor anchor = Anchor.center,
    required this.isSpawnRight,
  }) : super(position: position, size: enemySize, anchor: anchor);

  double mushroomSpeed = 170;
  bool isMushroomFacingRight = true;
  bool isDying = false;
  final int _sliceSize = 30;
  int _currentSlice = 0;
  Vector2 _currentVelocity = Vector2.zero();
  final Timer mushroomDeathTimer = Timer(0.39);
  final Timer bloodTimer = Timer(0.1);
  late final rectangleHitbox = RectangleHitbox.relative(
      parentSize: enemySize, Vector2(0.15, 0.25), position: enemySize * 0.42)
    ..debugMode = false;
  final bool isMushroomFollowsTheArhcer = Random().nextInt(100) < 35;
  late double mushroomHypotenuseSpeed = sqrt(mushroomSpeed * mushroomSpeed / 2);

  @override
  FutureOr<void> onLoad() {
    _loadAnimation();
    add(rectangleHitbox);
    deactivate();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.miniGameBloc.state.isArcherDead ||
        game.miniGameBloc.state.isTheGameReset) {
      deactivate();
    }

    if (isVisible) {
      if (isDying) {
        _bloodParticles(dt);
        _mushroomDeath(dt);
      } else {
        _mushroomMovement(dt);
      }
    } else {
      bloodTimer.reset();
    }

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Arrow && !isDying) {
      isDying = true;
      FlameAudio.play(AudioConstants.mushroomDeath);
    } else if (other is PlayerComponent) {
      deactivate();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _loadAnimation() {
    double time = 0.1;
    final runAnimation =
        _spriteAnimation(mushroomState: "Run", frameAmount: 8, stepTime: time);
    final deathAnimation = _spriteAnimation(
        mushroomState: "Death", frameAmount: 4, stepTime: time);
    final attackAnimation = _spriteAnimation(
        mushroomState: "Attack", frameAmount: 8, stepTime: time);

    animations = {
      MushroomState.run: runAnimation,
      MushroomState.death: deathAnimation,
      MushroomState.attack: attackAnimation,
    };
  }

  SpriteAnimation _spriteAnimation(
      {required String mushroomState,
      required int frameAmount,
      required double stepTime}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(_getMushroomImagePath(mushroomState)),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(150),
      ),
    );
  }

  String _getMushroomImagePath(String mushroomState) {
    switch (mushroomState) {
      case "Run":
        return ImageConstants.mushroomRun;
      case "Death":
        return ImageConstants.mushroomDeath;
      case "Attack":
        return ImageConstants.mushroomAttack;
      default:
        return ImageConstants.mushroomRun;
    }
  }

  void _mushroomMovement(double dt) {
    if (isMushroomFollowsTheArhcer) {
      _currentSlice++;
      if (_currentSlice >= _sliceSize) {
        _currentSlice = 0;
        _calculateVelocity();
      }
    } else {
      _calculateVelocity();
    }

    if (_currentVelocity.x < 0 && isMushroomFacingRight) {
      flipHorizontallyAroundCenter();
      isMushroomFacingRight = false;
    } else if (_currentVelocity.x > 0 && !isMushroomFacingRight) {
      flipHorizontallyAroundCenter();
      isMushroomFacingRight = true;
    }

    current = MushroomState.run;
    position.add(_currentVelocity * dt);

    if (isSpawnRight && position.x < 0) {
      deactivate();
      position = Vector2(game.background.size.x, 0);
    } else if (!isSpawnRight && position.x > game.background.size.x) {
      deactivate();
      position = Vector2(0, 0);
    }
  }

  void _calculateVelocity() {
    double directionX = 0.0;
    double directionY = 0.0;

    if (isSpawnRight) {
      if (isMushroomFollowsTheArhcer &&
          game.playerComponent.position.x < position.x) {
        directionX -= mushroomHypotenuseSpeed;
        if (game.playerComponent.position.y + 25 < position.y) {
          directionY -= mushroomHypotenuseSpeed;
        } else if (game.playerComponent.position.y - 25 > position.y) {
          directionY += mushroomHypotenuseSpeed;
        }
      } else {
        directionX -= mushroomSpeed;
      }
    } else {
      if (isMushroomFollowsTheArhcer &&
          game.playerComponent.position.x > position.x) {
        directionX += mushroomHypotenuseSpeed;
        if (game.playerComponent.position.y + 50 < position.y) {
          directionY -= mushroomHypotenuseSpeed;
        } else if (game.playerComponent.position.y - 50 > position.y) {
          directionY += mushroomHypotenuseSpeed;
        }
      } else {
        directionX += mushroomSpeed;
      }
    }

    _currentVelocity = Vector2(directionX, directionY);
  }

  void _bloodParticles(double dt) {
    if (bloodTimer.finished) {
      bloodTimer.pause();
    } else {
      bloodTimer.resume();
      bloodTimer.update(dt);
      add(game.bloodParticlesForMonsters(enemySize * 0.45));
    }
  }

  void _mushroomDeath(double dt) {
    rectangleHitbox.collisionType = CollisionType.inactive;
    mushroomDeathTimer.resume();
    mushroomDeathTimer.update(dt);
    current = MushroomState.death;
    if (mushroomDeathTimer.finished) {
      deactivate();
      isDying = false;
      mushroomDeathTimer.stop();
    }
  }

  void activate() {
    isVisible = true;
    rectangleHitbox.collisionType = CollisionType.active;
  }

  void deactivate() {
    isVisible = false;
    rectangleHitbox.collisionType = CollisionType.inactive;
  }
}
