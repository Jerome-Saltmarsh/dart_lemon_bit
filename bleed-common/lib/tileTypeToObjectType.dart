import 'Tile.dart';
import 'ObjectType.dart';

const tileTypeToObjectType = <int, ObjectType> {
  Tile.Block_Grass: ObjectType.Block_Grass,
  Tile.Rock_Wall: ObjectType.Rock_Wall,
  Tile.Palisade: ObjectType.Palisade,
};
