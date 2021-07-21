import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_resources.dart';
import 'package:howler/howler.dart';

Image spriteTemplate;
Image tileGrass01;
Howl shotgunFireAudio;

Future loadResources() async {
  tileGrass01 = await loadImage("images/tile-grass-01.png");
  spriteTemplate = await loadImage("images/iso-character.png");
  shotgunFireAudio = Howl(
      src: [
        'audio/shotgun-fire.mp3',
      ], // source in MP3 and WAV fallback
      loop: false, // Loops the sound when play ends.
      volume: 0.60, // Play with 60% of original volume.
      preload: true // Automatically loads source.
  );
  shotgunFireAudio.load();
}
