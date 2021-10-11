
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
      return _blockHorizontal;
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
    case Tile.Crate:
      return _crate;
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
Rect _concrete = _frame(8);
Rect _zombieSpawn = _frame(9);
Rect _playerSpawn = _frame(10);
Rect _water = _frame(9);
Rect _crate = _frame(12);

Rect _frame(int index) {
  return Rect.fromLTWH((index - 1) * tileCanvasWidth.toDouble(), 0.0, tileCanvasWidth.toDouble(), tileCanvasHeight.toDouble());
}