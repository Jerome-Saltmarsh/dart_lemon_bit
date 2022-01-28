
import 'package:bleed_client/common/Tile.dart';

import '../rects.dart';

// interface
double mapTileToSrc(Tile tile) {
  switch (tile) {
    case Tile.Concrete:
      return _concrete;
    case Tile.Grass:
      return _grass;
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
}

// abstraction
final _grass = _frame(1);
final _grass02 = _frame(1);
final _longGrass = _frame(2);
final _block = _frame(3);
final _concrete = _frame(4);
final _concreteHorizontal = _concrete;
final _concreteVertical =  _concrete;
final _water = _frame(5);
final _rune = _frame(6);
final _zombieSpawn = _frame(7);
final _flowers = _longGrass;
final rectSrcDarkness = _frame(8);
final _bridge = _frame(9);
final _woodenFloor = _frame(10);
final _rock = _frame(11);
final _black = _frame(12);
final _rockWall = _frame(13);

double _frame(int index) => (index - 1) * tileCanvasWidth.toDouble();