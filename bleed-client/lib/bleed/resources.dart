import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_resources.dart';

Image imageHuman;
Image imageTiles;
Image tileGrass01;

Future loadResources() async {
  await _loadImages();
}

Future<void> _loadImages() async {
  tileGrass01 = await loadImage("images/tile-grass-01.png");
  imageHuman = await loadImage("images/iso-character.png");
  imageTiles = await loadImage("images/Tiles.png");
}

