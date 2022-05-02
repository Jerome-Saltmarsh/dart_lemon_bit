import 'Tile.dart';

const tileTypeToObjectType = <int, int> {
  Tile.Block_Grass: GeneratedObjectType.Block_Grass,
  Tile.Block_Grass_Level_2: GeneratedObjectType.Block_Grass_Level_2,
  Tile.Rock_Wall: GeneratedObjectType.Block_Stone,
};

class GeneratedObjectType {
  static const Block_Grass = 0;
  static const Block_Grass_Level_2 = 1;
  static const Block_Stone = 2;
}