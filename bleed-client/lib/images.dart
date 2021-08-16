import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/game_engine/game_resources.dart';

import 'classes/SpriteSheet.dart';

Image imageCharacter;
Image imageTiles;
Image imageExplosion;
Image imageParticles;
Image imageHandgun;
Image imageHandgunAmmo;
SpriteSheet spritesExplosion;

Future loadImages() async {
  print("loading images");
  imageCharacter = await loadImage("images/character.png");
  imageTiles = await loadImage("images/tiles.png");
  imageExplosion = await loadImage('images/explosion.png');
  imageParticles = await loadImage('images/particles.png');
  imageHandgun = await loadImage('images/weapon-handgun.png');
  imageHandgunAmmo = await loadImage('images/handgun-ammo.png');
  print("loading images complete");
  spritesExplosion = SpriteSheet(32, imageExplosion, 8, 4);
}


