
import 'dart:ui';

import 'package:bleed_client/common/Tile.dart';

import '../rects.dart';

// interface
Rect mapTileToSrcRect(Tile tile) {
  switch (tile) {
    case Tile.Concrete:
      return _concrete;
    case Tile.Grass:
      return _grass;
    case Tile.Fortress:
      return _playerSpawn;
    case Tile.PlayerSpawn:
      return _playerSpawn;
    case Tile.ZombieSpawn:
      return _zombieSpawn;
    case Tile.RandomItemSpawn:
      return _concrete;
    case Tile.Block:
      return _grass;
    case Tile.Block_Horizontal:
      return _grass;
    case Tile.Block_Vertical:
      return _grass;
    case Tile.Water:
      return _water;
    case Tile.Water_Side_01:
      return _waterSide01;
    case Tile.Water_Side_02:
      return _waterSide02;
    case Tile.Water_Side_03:
      return _waterSide03;
    case Tile.Water_Side_04:
      return _waterSide04;
    case Tile.Water_Corner_01:
      return _waterCorner01;
    case Tile.Water_Corner_02:
      return _waterCorner02;
    case Tile.Water_Corner_03:
      return _waterCorner03;
    case Tile.Water_Corner_04:
      return _waterCorner04;
    case Tile.Long_Grass:
      return _longGrass;
    case Tile.Flowers:
      return _flowers;
    case Tile.Grass02:
      return _grass02;
    case Tile.Concrete_Horizontal:
      return _concreteHorizontal;
    case Tile.Concrete_Vertical:
      return _concreteVertical;
    case Tile.Boundary:
      throw Exception("Boundary has no rect");
  }
  throw Exception("could not find rect for tile $tile");
}

// abstraction
Rect _grass = _frame(1);
Rect _grass02 = _frame(1);
Rect _concrete = _frame(13);
Rect _concreteHorizontal = _frame(13);
Rect _concreteVertical = _frame(13);
Rect _water = _frame(16);
Rect _waterSide01 = _frame(16);
Rect _waterSide02 = _frame(16);
Rect _waterSide03 = _frame(16);
Rect _waterSide04 = _frame(16);
Rect _waterCorner01 = _frame(16);
Rect _waterCorner02 = _frame(16);
Rect _waterCorner03 = _frame(16);
Rect _waterCorner04 = _frame(16);
Rect _playerSpawn = _frame(19);
Rect _zombieSpawn = _frame(22);
Rect _longGrass = _frame(25);
Rect _flowers = _frame(25);
Rect rectSrcDarkness = _frame(28);

Rect _frame(int index) {
  return Rect.fromLTWH(
      (index - 1) * tileCanvasWidth.toDouble(),
      0.0,
      tileCanvasWidth.toDouble(),
      tileCanvasHeight.toDouble()
  );
}