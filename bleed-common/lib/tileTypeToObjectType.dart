import 'Tile.dart';
import 'enums/ObjectType.dart';

const tileTypeToObjectType = <int, ObjectType> {
  Tile.Block_Grass: ObjectType.Block_Grass,
  Tile.Rock_Wall: ObjectType.Rock_Wall,
  Tile.Block: ObjectType.Palisade,
  Tile.Block_Horizontal: ObjectType.Palisade_H,
  Tile.Block_Vertical: ObjectType.Palisade_V,
};
