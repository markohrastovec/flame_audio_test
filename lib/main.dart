import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';

List<String> imageFiles = <String>[
  'fire.png',
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();

  final game = MainGame();

  runApp(GameWidget(game: game));
}

class MainGame extends FlameGame with MultiTouchTapDetector, MultiTouchDragDetector {
  AudioPlayer? loopPlayer;
  Set<int> activeDrag = <int>{};

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    for (int i = 0; i < imageFiles.length; i++) {
      await images.load(imageFiles[i]);
    }
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) async {
    if (loopPlayer == null && activeDrag.isEmpty) {
      loopPlayer = await FlameAudio.audioCache.loop('sfx/flame.mp3');
    }
    activeDrag.add(pointerId);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    add(FireComponent()
      ..position = info.eventPosition.game
      ..anchor = Anchor.center);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) async {
    activeDrag.remove(pointerId);
    if (loopPlayer != null && activeDrag.isEmpty) {
      int result = await loopPlayer!.stop();
      loopPlayer = null;
    }
  }

  @override
  void onDragCancel(int pointerId) async {
    activeDrag.remove(pointerId);
    if (loopPlayer != null && activeDrag.isEmpty) {
      int result = await loopPlayer!.stop();
      loopPlayer = null;
    }
  }
}

class FireComponent extends PositionComponent with HasGameRef<MainGame>{
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(
      ParticleComponent(
        TranslatedParticle(
          offset: Vector2(-128.0, -128.0),
          lifespan: 0.167,
          child: SpriteAnimationParticle(
            animation: SpriteAnimation.spriteList(
              List<Sprite>.generate(10, SpriteSheet.fromColumnsAndRows(
                image: gameRef.images.fromCache('fire.png'),
                columns: 10,
                rows: 1,
              ).getSpriteById),
              stepTime: 1.0,
            ),
            size: Vector2(128, 128),
            lifespan: 0.167,
          ),
        ),
      ),
    );
  }
}