
import 'dart:ui';

import 'package:bleed_client/common/Tile.dart';

import '../rects.dart';

Rect tileRectConcrete = getTileSpriteRectByIndex(0);
Rect tileRectGrass = getTileSpriteRectByIndex(1);
Rect tileRectRed = getTileSpriteRectByIndex(2);
Rect tileRectYellow = getTileSpriteRectByIndex(3);
Rect tileRectBlue = getTileSpriteRectByIndex(4);
Rect tileRectGreen = getTileSpriteRectByIndex(5);
Rect tileRectPurple = getTileSpriteRectByIndex(6);


Rect getTileSpriteRect(Tile tile) {
  switch (tile) {
    case Tile.Concrete:
      return tileRectConcrete;
    case Tile.Grass:
      return tileRectGrass;
    case Tile.Fortress:
      return tileRectYellow;
    case Tile.PlayerSpawn:
      return tileRectBlue;
    case Tile.ZombieSpawn:
      return tileRectRed;
    case Tile.RandomItemSpawn:
      return tileRectPurple;
  }
  throw Exception("could not find rect for tile $tile");
}

Rect getTileSpriteRectByIndex(int index) {
  return rectByIndex(
      index, tileCanvasWidth.toDouble(), tileCanvasHeight.toDouble());
}

Rect rectByIndex(int index, double frameWidth, double height) {
  return Rect.fromLTWH(index * frameWidth, 0.0, frameWidth, height);
}