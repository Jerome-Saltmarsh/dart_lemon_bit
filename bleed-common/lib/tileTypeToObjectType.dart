import 'Tile.dart';

const tileTypeToObjectType = <int, int> {
  Tile.Block_Grass: GeneratedObjectType.Block_Grass,
  Tile.Rock_Wall: GeneratedObjectType.Block_Stone,
};

class GeneratedObjectType {
  static const Block_Grass = 1;
  static const Block_Stone = 2;
}