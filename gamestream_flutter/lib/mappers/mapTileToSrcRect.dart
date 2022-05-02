
import 'package:bleed_common/Tile.dart';

double mapTileToSrcLeft(int tile) {
  switch (tile) {
    case Tile.Concrete:
      return _concrete;
    case Tile.Grass:
      return _grass;
    case Tile.Zombie_Spawn:
      return _zombieSpawn;
    case Tile.Random_Item_Spawn:
      return _concrete;
    case Tile.Palisade:
        return _palisade;
    case Tile.Water:
      return water;
    case Tile.Long_Grass:
      return _longGrass;
    case Tile.Flowers:
      return _flowers;
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
    case Tile.Block_Grass:
      return _rockWall;
    case Tile.Block_Grass_Level_2:
      return _rockWall;
    case Tile.Block_Grass_Level_3:
      return _rockWall;
    case Tile.Boundary:
      throw Exception("Boundary has no rect");
    default:
      throw Exception("Cannot map left");
  }
}

// abstraction
final _grass = _frame(1);
final _longGrass = _frame(2);
final _palisade = _frame(3);
final _concrete = _frame(4);
final water = _frame(5);
final _zombieSpawn = _frame(7);
final _flowers = _longGrass;
final _bridge = _frame(9);
final _woodenFloor = _frame(10);
final _rock = _frame(11);
final _black = _frame(12);
final _rockWall = _frame(13);
final waterCorner1 = _frame(14);
final waterCorner2 = _frame(15);
final waterCorner3 = _frame(16);
final waterCorner4 = _frame(17);
final waterHor = _frame(18);
final waterVer = _frame(19);

double _frame(int index) => (index - 1) * 48.0;