
import 'dart:ui';

import 'package:bleed_client/common/Tile.dart';

import '../rects.dart';

// interface
Rect mapTileToRect(Tile tile) {
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
      return _blockFull;
    case Tile.Block_Horizontal:
      return _blockHorizontal;
    case Tile.Block_Vertical:
      return _blockVertical;
    case Tile.Block_Corner_01:
      return _blockCorner01;
    case Tile.Block_Corner_02:
      return _blockCorner02;
    case Tile.Block_Corner_03:
      return _blockCorner03;
    case Tile.Block_Corner_04:
      return _blockCorner04;
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
    case Tile.Crate:
      return _crate;
    case Tile.Long_Grass:
      return _longGrass;
    case Tile.Boundary:
      throw Exception("Boundary has no rect");
  }
  throw Exception("could not find rect for tile $tile");
}

// abstraction
Rect _grass = _frame(1);
Rect _blockHorizontal = _frame(2);
Rect _blockVertical = _frame(3);
Rect _blockCorner01 = _frame(4);
Rect _blockCorner02 = _frame(5);
Rect _blockCorner03 = _frame(6);
Rect _blockCorner04 = _frame(7);
Rect _blockFull = _frame(8);
Rect _concrete = _frame(9);
Rect _crate = _frame(9);
Rect _water = _frame(10);
Rect _waterSide01 = _frame(11);
Rect _waterSide02 = _frame(12);
Rect _waterSide03 = _frame(13);
Rect _waterSide04 = _frame(14);
Rect _waterCorner01 = _frame(15);
Rect _waterCorner02 = _frame(16);
Rect _waterCorner03 = _frame(17);
Rect _waterCorner04 = _frame(18);
Rect _playerSpawn = _frame(19);
Rect _zombieSpawn = _frame(20);
Rect _longGrass = _frame(21);


Rect _frame(int index) {
  return Rect.fromLTWH((index - 1) * tileCanvasWidth.toDouble(), 0.0, tileCanvasWidth.toDouble(), tileCanvasHeight.toDouble());
}