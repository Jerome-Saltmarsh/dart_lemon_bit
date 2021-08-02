import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_resources.dart';
import 'package:howler/howler.dart';

Image imageHuman;
Image imageTiles;
Image tileGrass01;
Howl shotgunFireAudio;
Howl pistolFireAudio;

Future loadResources() async {
  tileGrass01 = await loadImage("images/tile-grass-01.png");
  imageHuman = await loadImage("images/iso-character.png");
  imageTiles = await loadImage("images/Tiles.png");
}

Future loadAudioFiles(){
  print("loading audio files");
  shotgunFireAudio = loadAudio('audio/shotgun-fire.mp3');
  pistolFireAudio = loadAudio('audio/pistol-fire.mp3');
}

Howl loadAudio(String fileName, {double volume = 0.6}){
  Howl howl =  Howl(
      src: [fileName],
      loop: false,
      volume: volume,
      preload: true,
      html5: true,
  );
  howl.load();
  return howl;
}

