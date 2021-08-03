import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_resources.dart';
import 'package:universal_html/html.dart';

Image imageHuman;
Image imageTiles;
Image tileGrass01;
AudioElement handgunPistolShot;

Future loadResources() async {
  await _loadImages();
}

Future<void> _loadImages() async {
  tileGrass01 = await loadImage("images/tile-grass-01.png");
  imageHuman = await loadImage("images/iso-character.png");
  imageTiles = await loadImage("images/Tiles.png");
}

void loadAudioFiles(){
  print('loading audio files');
  handgunPistolShot = new AudioElement();
  handgunPistolShot.id = 'handgun-shot';
  handgunPistolShot.src = 'audio/handgun-shot.mp3';
  // shotgunFireAudio = loadAudio('audio/shotgun-fire.mp3');
  // pistolFireAudio = loadAudio('audio/handgun-shot.mp3');
}


