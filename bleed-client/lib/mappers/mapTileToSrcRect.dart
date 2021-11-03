
import 'dart:ui';

import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/properties.dart';

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
      if (editMode) {
        return _block;
      }
      return _grass;
    case Tile.Block_Horizontal:
      if (editMode) {
        return _block;
      }
      return _grass;
    case Tile.Block_Vertical:
      if (editMode) {
        return _block;
      }
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
Rect _concrete = _frame(5);
Rect _block = _frame(4);
Rect _concreteHorizontal = _concrete;
Rect _concreteVertical =  _concrete;
Rect _water = _frame(8);
Rect _waterSide01 = _water;
Rect _waterSide02 = _water;
Rect _waterSide03 = _water;
Rect _waterSide04 = _water;
Rect _waterCorner01 = _water;
Rect _waterCorner02 = _water;
Rect _waterCorner03 = _water;
Rect _waterCorner04 = _water;
Rect _playerSpawn = _frame(11);
Rect _zombieSpawn = _frame(14);
Rect _longGrass = _frame(17);
Rect _flowers = _longGrass;
Rect rectSrcDarkness = _frame(20);

Rect _frame(int index) {
  return Rect.fromLTWH(
      (index - 1) * tileCanvasWidth.toDouble(),
      0.0,
      tileCanvasWidth.toDouble(),
      tileCanvasHeight.toDouble()
  );
}