import 'Tile.dart';

const tileTypeToObjectType = <int, int> {
  Tile.Block_Grass: GeneratedObjectType.Block_Grass,
  Tile.Block_Grass_Level_2: GeneratedObjectType.Block_Grass_Level_2,
  Tile.Block_Grass_Level_3: GeneratedObjectType.Block_Grass_Level_3,
  Tile.Rock_Wall: GeneratedObjectType.Block_Stone,
  Tile.Stairs_Grass_H: GeneratedObjectType.Stairs_Grass_H,
};

class GeneratedObjectType {
  static const Block_Grass = 0;
  static const Block_Grass_Level_2 = 1;
  static const Block_Grass_Level_3 = 2;
  static const Block_Stone = 3;
  static const Stairs_Grass_H = 4;
}