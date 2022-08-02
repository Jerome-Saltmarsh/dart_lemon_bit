

import '../common/library.dart';
import 'character.dart';
import 'game.dart';

abstract class Node {
  bool getCollision(double x, double y, double z);
  void resolveCharacterCollision(Character character, Game game);

  int get type;

  static final Node boundary = NodeBoundary();
  static final Node grass = NodeGrass();
  static final Node bricks = NodeBricks();
  static final Node wood = NodeWood();
  static final Node soil = NodeSoil();
  static final Node stone = NodeStone();
  static final Node treeTop = NodeTreeTop();
  static final Node empty = NodeEmpty();
  static final Node water = NodeWater();
  static final Node waterFlowing = NodeWaterFlowing();
}

class NodeEmpty extends Node {
  @override
  bool getCollision(double x, double y, double z) => false;

  @override
  void resolveCharacterCollision(Character character, Game game) {

  }

  @override
  int get type => GridNodeType.Empty;
}

class NodeBoundary extends Node {
  @override
  bool getCollision(double x, double y, double z) => true;

  @override
  void resolveCharacterCollision(Character character, Game game) {
    // push the character back into the world
  }

  @override
  int get type => GridNodeType.Boundary;
}

abstract class NodeSolid extends Node {

  @override
  bool getCollision(double x, double y, double z) => true;

  @override
  void resolveCharacterCollision(Character character, Game game) {
    character.z += tileHeight - (character.z % tileHeight);
    character.zVelocity = 0;
  }
}

class NodeGrass extends NodeSolid {
  @override
  int get type => GridNodeType.Grass;
}

class NodeBricks extends NodeSolid {
  @override
  int get type => GridNodeType.Bricks;
}

class NodeWater extends Node {

  @override
  bool getCollision(double x, double y, double z) => true;

  @override
  void resolveCharacterCollision(Character character, Game game) {
    game.dispatchV3(GameEventType.Splash, character);
    game.setCharacterStateDead(character);
  }

  @override
  int get type => GridNodeType.Water;
}

class NodeWaterFlowing extends Node {

  @override
  bool getCollision(double x, double y, double z) => true;

  @override
  void resolveCharacterCollision(Character character, Game game) {
    game.dispatchV3(GameEventType.Splash, character);
    game.setCharacterStateDead(character);
  }

  @override
  int get type => GridNodeType.Water_Flowing;
}

abstract class NodeSlope extends Node {

  @override
  bool getCollision(double x, double y, double z) {
    return getHeightAt(x, y, z) > z;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    character.z = getHeightAt(character.x, character.y, character.z);
    character.zVelocity = 0;
  }

  double getHeightAt(double x, double y, double z);
}

abstract class NodeSlopeNorth extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    final percentage = 1 - ((x % tileSize) / tileSize);
    final bottom = (z ~/ tileHeight) * tileHeight;
    return (percentage * tileHeight) + bottom;
  }
}

abstract class NodeSlopeEast extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percentage = 1 - ((y % tileSize) / tileSize);
    return (percentage * tileHeight) + bottom;
  }
}

abstract class NodeSlopeSouth extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percentage = ((x % tileSize) / tileSize);
    return (percentage * tileHeight) + bottom;
  }
}

abstract class NodeSlopeWest extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percentage = ((y % tileSize) / tileSize);
    return (percentage * tileHeight) + bottom;
  }
}

class NodeStairsNorth extends NodeSlopeNorth {
  @override
  int get type => GridNodeType.Stairs_North;
}

class NodeStairsEast extends NodeSlopeEast {
  @override
  int get type => GridNodeType.Stairs_East;
}

class NodeStairsSouth extends NodeSlopeSouth {
  @override
  int get type => GridNodeType.Stairs_South;
}

class NodeStairsWest extends NodeSlopeWest {
  @override
  int get type => GridNodeType.Stairs_West;
}

abstract class NodeRadial extends Node {
  double get radius;

  @override
  bool getCollision(double x, double y, double z) {
    final percRow = (x / 48.0) % 1.0;
    if ((0.5 - percRow).abs() > radius) return false;
    final percColumn = (y / 48.0) % 1.0;
    if ((0.5 - percColumn).abs() > radius) return false;
    return true;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    // TODO: implement resolveCharacterCollision
  }
}

class NodeTorch extends NodeRadial {
  @override
  int get type => GridNodeType.Torch;

  @override
  double get radius => 0.2;
}

class NodeTreeBottom extends NodeRadial {
  @override
  int get type => GridNodeType.Tree_Bottom;

  @override
  double get radius => 0.2;
}

class NodeTreeTop extends Node {
  @override
  int get type => GridNodeType.Tree_Top;

  @override
  bool getCollision(double x, double y, double z) {
    const treeRadius = 0.2;
    final percRow = (x / 48.0) % 1.0;
    if ((0.5 - percRow).abs() > treeRadius) return false;
    final percColumn = (y / 48.0) % 1.0;
    if ((0.5 - percColumn).abs() > treeRadius) return false;
    return true;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    // TODO: implement resolveCharacterCollision
  }
}

class NodeGrassLong extends Node {
  @override
  int get type => GridNodeType.Grass_Long;

  @override
  bool getCollision(double x, double y, double z) => false;

  @override
  void resolveCharacterCollision(Character character, Game game) {

  }
}

class NodeWood extends NodeSolid {
  @override
  int get type => GridNodeType.Wood;
}

class NodeFireplace extends NodeRadial {
  @override
  int get type => GridNodeType.Fireplace;

  @override
  double get radius => 0.4;
}

class NodeGrassSlopeNorth extends NodeSlopeNorth {
  @override
  int get type => GridNodeType.Grass_Slope_North;
}

class NodeGrassSlopeEast extends NodeSlopeEast {
  @override
  int get type => GridNodeType.Grass_Slope_East;
}

class NodeGrassSlopeSouth extends NodeSlopeSouth {
  @override
  int get type => GridNodeType.Grass_Slope_South;
}

class NodeGrassSlopeWest extends NodeSlopeWest {
  @override
  int get type => GridNodeType.Grass_Slope_West;
}

class NodeBrickTop extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return y % tileHeight > tileHeightHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
      character.z += tileHeight - (character.z % tileHeight);
      character.zVelocity = 0;
  }

  @override
  int get type => GridNodeType.Brick_Top;
}

class NodeWoodHalfRow1 extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) > tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    // TODO: implement resolveCharacterCollision
  }

  @override
  int get type => GridNodeType.Wood_Half_Row_1;
}

class NodeWoodHalfRow2 extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) < tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    // TODO: implement resolveCharacterCollision
  }

  @override
  int get type => GridNodeType.Wood_Half_Row_2;
}

class NodeWoodHalfColumn1 extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (x % tileSize) > tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    // TODO: implement resolveCharacterCollision
  }

  @override
  int get type => GridNodeType.Wood_Half_Column_1;
}


class NodeWoodHalfColumn2 extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (x % tileSize) < tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    // TODO: implement resolveCharacterCollision
  }

  @override
  int get type => GridNodeType.Wood_Half_Column_2;
}

class NodeRoofTileNorth extends NodeSlopeNorth {
  @override
  int get type => GridNodeType.Roof_Tile_North;
}

class NodeRoofTileSouth extends NodeSlopeSouth {
  @override
  int get type => GridNodeType.Roof_Tile_South;
}

class NodeSoil extends NodeSolid {
  @override
  int get type => GridNodeType.Soil;
}

class NodeRoofHayNorth extends NodeSlopeNorth {
  @override
  int get type => GridNodeType.Roof_Hay_North;
}

class NodeRoofHaySouth extends NodeSlopeSouth {
  @override
  int get type => GridNodeType.Roof_Hay_South;
}

class NodeStone extends NodeSolid {
  @override
  int get type => GridNodeType.Stone;
}

class NodeGrassSlopeTop extends NodeSlope {


  @override
  int get type => GridNodeType.Grass_Slope_Top;

  @override
  double getHeightAt(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percentageX = ((x % tileSize) / tileSize);
    final percentageY = ((y % tileSize) / tileSize);
    final total = percentageX + percentageY;
    if (total < 1) return bottom;
    final perc = total - 1.0;
    return bottom + (tileHeight * perc);
  }
}

class NodeGrassSlopeRight extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percX = ((x % tileSize) / tileSize);
    final percY = ((y % tileSize) / tileSize);
    final tX = (percY - percX);
    if (tX < 0) return bottom;
    return bottom + (tileHeight * tX);
  }

  @override
  int get type => GridNodeType.Grass_Slope_Right;
}

class NodeGrassSlopeBottom extends NodeSlope {

  @override
  int get type => GridNodeType.Grass_Slope_Bottom;

  @override
  double getHeightAt(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percentageX = ((x % tileSize) / tileSize);
    final percentageY = ((y % tileSize) / tileSize);
    final total = percentageX + percentageY;
    if (total > 1) return bottom;
    final perc = 1.0 - total;
    return bottom + (tileHeight * perc);
  }
}

class NodeGrassSlopeLeft extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percX = ((x % tileSize) / tileSize);
    final percY = ((y % tileSize) / tileSize);
    final tX = (percX - percY);
    if (tX < 0) return bottom;
    return bottom + (tileHeight * tX);
  }

  @override
  int get type => GridNodeType.Grass_Slope_Left;
}

class NodeWoodCornerTop extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) < tileSizeHalf ||  (x % tileSize) < tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
  }

  @override
  int get type => GridNodeType.Wood_Corner_Top;
}

class NodeWoodCornerRight extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) < tileSizeHalf ||  (x % tileSize) > tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
  }

  @override
  int get type => GridNodeType.Wood_Corner_Right;
}

class NodeWoodCornerBottom extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) > tileSizeHalf ||  (x % tileSize) > tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
  }

  @override
  int get type => GridNodeType.Wood_Corner_Bottom;
}

class NodeWoodCornerLeft extends Node {
  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) > tileSizeHalf ||  (x % tileSize) < tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
  }

  @override
  int get type => GridNodeType.Wood_Corner_Left;
}


class NodeGrassEdgeTop extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    return z;
  }

  @override
  int get type => GridNodeType.Grass_Edge_Top;
}

class NodeGrassEdgeRight extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    return z;
  }

  @override
  int get type => GridNodeType.Grass_Edge_Right;
}

class NodeGrassEdgeBottom extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    final percentageX = ((x % tileSize) / tileSize);
    final percentageY = ((y % tileSize) / tileSize);
    final total = percentageX + percentageY;
    final bottom = (z ~/ tileHeight) * tileHeight;
    if (total < 1) return bottom + tileHeight;
    final perc = 1 - (total - 1);
    return bottom + (tileHeight * perc);
  }

  @override
  int get type => GridNodeType.Grass_Edge_Bottom;
}

class NodeGrassEdgeLeft extends NodeSlope {
  @override
  double getHeightAt(double x, double y, double z) {
    return z;
  }

  @override
  int get type => GridNodeType.Grass_Edge_Left;
}