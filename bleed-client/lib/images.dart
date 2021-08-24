import 'dart:async';
import 'dart:ui';

import 'package:bleed_client/game_engine/game_resources.dart';

import 'classes/SpriteSheet.dart';

Image imageCharacter;
Image imageTiles;
Image imageParticles;
Image imageHandgun;
Image imageHandgunAmmo;
Image imageItems;
Image imageShotgunAmmo;
SpriteSheet spritesExplosion;

Future loadImages() async {
  print("loading images");
  imageCharacter = await loadImage("images/character.png");
  imageTiles = await loadImage("images/tiles.png");
  imageParticles = await loadImage('images/particles.png');
  imageHandgun = await loadImage('images/weapon-handgun.png');
  imageHandgunAmmo = await loadImage('images/handgun-ammo.png');
  imageShotgunAmmo = await loadImage('images/shotgun-ammo.png');
  imageItems = await loadImage("images/items.png");
  print("loading images complete");
}


