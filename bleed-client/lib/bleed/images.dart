import 'dart:ui';

import 'package:flutter_game_engine/bleed/classes.dart';
import 'package:flutter_game_engine/game_engine/game_resources.dart';

Image imageHuman;
Image imageTiles;
Image tileGrass01;
Image imagesExplosion;

SpriteSheet spritesExplosion;

Future loadImages() async {
  print("loading images");
  tileGrass01 = await loadImage("images/tile-grass-01.png");
  imageHuman = await loadImage("images/iso-character.png");
  imageTiles = await loadImage("images/Tiles.png");
  imagesExplosion = await loadImage('images/explosion.png');
  print("loading images complete");


  spritesExplosion = SpriteSheet(32, imagesExplosion, 8, 4);
}


