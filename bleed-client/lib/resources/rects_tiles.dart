
import 'dart:ui';

import 'package:bleed_client/common/Tile.dart';

import '../rects.dart';

Rect tileRectGrass = getTileSpriteRectByIndex(0);
Rect tileRectBlock = getTileSpriteRectByIndex(1);
Rect tileRectConcrete = getTileSpriteRectByIndex(2);
Rect tileRectOrange = getTileSpriteRectByIndex(3);
Rect tileRectRed = getTileSpriteRectByIndex(4);
Rect tileRectBlack = getTileSpriteRectByIndex(4);


Rect getTileSpriteRect(Tile tile) {
  switch (tile) {
    case Tile.Concrete:
      return tileRectConcrete;
    case Tile.Grass:
      return tileRectGrass;
    case Tile.Fortress:
      return tileRectOrange;
    case Tile.PlayerSpawn:
      return tileRectBlack;
    case Tile.ZombieSpawn:
      return tileRectRed;
    case Tile.RandomItemSpawn:
      return tileRectOrange;
    case Tile.Block:
      return tileRectBlock;
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