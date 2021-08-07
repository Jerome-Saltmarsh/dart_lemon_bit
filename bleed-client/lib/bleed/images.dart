import 'dart:async';
import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_resources.dart';

import 'classes/SpriteSheet.dart';

Image imageCharacter;
Image imageTiles;
Image imageExplosion;
Image imageParticles;
SpriteSheet spritesExplosion;

Future loadImages() async {
  print("loading images");
  imageCharacter = await loadImage("images/character.png");
  imageTiles = await loadImage("images/Tiles.png");
  imageExplosion = await loadImage('images/explosion.png');
  imageParticles = await loadImage('images/particles.png');
  print("loading images complete");
  spritesExplosion = SpriteSheet(32, imageExplosion, 8, 4);
}


