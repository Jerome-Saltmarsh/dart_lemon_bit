import 'dart:ui';

import 'package:flutter_game_engine/game_engine/game_resources.dart';

Image spriteTemplate;
Image tileGrass01;

Future loadImages() async {
  tileGrass01 = await loadImage("images/tile-grass-01.png");
  spriteTemplate = await loadImage("images/iso-character.png");
}
