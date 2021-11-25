
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
        return _block;
    case Tile.Block_Horizontal:
      return _block;
    case Tile.Block_Vertical:
      return _block;
    case Tile.Water:
      return _water;
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
    case Tile.Bridge:
      return _bridge;
    case Tile.Wooden_Floor:
      return _woodenFloor;
    case Tile.Rock:
      return _rock;
    case Tile.Black:
      return _black;
    case Tile.Rock_Wall:
      return _rockWall;
    case Tile.Boundary:
      throw Exception("Boundary has no rect");
  }
  throw Exception("could not find rect for tile $tile");
}

// abstraction
Rect _grass = _frame(1);
Rect _grass02 = _frame(1);
Rect _longGrass = _frame(2);
Rect _block = _frame(3);
Rect _concrete = _frame(4);
Rect _concreteHorizontal = _concrete;
Rect _concreteVertical =  _concrete;
Rect _water = _frame(5);
Rect _playerSpawn = _frame(6);
Rect _zombieSpawn = _frame(7);
Rect _flowers = _longGrass;
Rect rectSrcDarkness = _frame(8);
Rect _bridge = _frame(9);
Rect _woodenFloor = _frame(10);
Rect _rock = _frame(11);
Rect _black = _frame(12);
Rect _rockWall = _frame(13);


Rect _frame(int index) {
  return Rect.fromLTWH(
      (index - 1) * tileCanvasWidth.toDouble(),
      0.0,
      tileCanvasWidth.toDouble(),
      tileCanvasHeight.toDouble()
  );
}