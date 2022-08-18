

import '../common/library.dart';
import 'character.dart';
import 'game.dart';

abstract class Node {
  int get type;
  bool getCollision(double x, double y, double z);
  void resolveCharacterCollision(Character character, Game game);

  bool get isEmpty => type == NodeType.Empty;


  static final Node boundary = NodeBoundary();
  static final Node grass = NodeGrass();
  static final Node grassFlowers = NodeGrassFlowers();
  static final Node bricks = NodeBricks();
  static final Node wood = NodeWood();
  static final Node soil = NodeSoil();
  static final Node stone = NodeStone();
  static final Node treeTop = NodeTreeTop();
  static final Node empty = NodeEmpty();
  static final Node water = NodeWater();
  static final Node waterFlowing = NodeWaterFlowing();
}

abstract class NodeNoneCollidable extends Node {
  @override
  bool getCollision(double x, double y, double z) => false;

  @override
  void resolveCharacterCollision(Character character, Game game) {

  }
}

class NodeEmpty extends NodeNoneCollidable {
  @override
  int get type => NodeType.Empty;
}

class NodeBoundary extends Node {
  @override
  bool getCollision(double x, double y, double z) => true;

  @override
  void resolveCharacterCollision(Character character, Game game) {
    if (character.x < 0){
      character.x = 0;
    }
    if (character.y < 0){
      character.y = 0;
    }
    if (character.x > game.scene.gridRowLength) {
      character.x = game.scene.gridRowLength;
    }
    if (character.y > game.scene.gridColumnLength) {
      character.y = game.scene.gridColumnLength;
    }
  }

  @override
  int get type => NodeType.Boundary;
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
  int get type => NodeType.Grass;
}

class NodeGrassFlowers extends NodeSolid {
  @override
  int get type => NodeType.Grass_Flowers;
}

class NodeBricks extends NodeSolid {
  @override
  int get type => NodeType.Bricks;
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
  int get type => NodeType.Water;
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
  int get type => NodeType.Water_Flowing;
}

abstract class NodeSlope extends Node {

  @override
  bool getCollision(double x, double y, double z) {
    return getHeight(x, y, z) > z;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    character.z = getHeight(character.x, character.y, character.z);
    character.zVelocity = 0;
  }

  double getHeight(double x, double y, double z){
    final bottom = (z ~/ tileHeight) * tileHeight;
    final percX = ((x % tileSize) / tileSize);
    final percY = ((y % tileSize) / tileSize);
    assert (percX >= 0 && percX <= 1);
    assert (percY >= 0 && percY <= 1);
    return bottom + (getGradient(percX, percY) * tileHeight);
  }

  /// Returns a value between 0 and 1 which indicates the height of this given position
  /// Arguments percX and percY are both values between 0 and 1 representing the relative position on the tile
  double getGradient(double percX, double percY);

}

abstract class NodeSlopeNorth extends NodeSlope {
  @override
  double getGradient(double x, double y) {
    return 1 - x;
  }
}

abstract class NodeSlopeEast extends NodeSlope {
  @override
  double getGradient(double x, double y) {
    return 1- y;
  }
}

abstract class NodeSlopeSouth extends NodeSlope {
  @override
  double getGradient(double x, double y) {
    return x;
  }
}

abstract class NodeSlopeWest extends NodeSlope {
  @override
  double getGradient(double x, double y) {
    return y;
  }
}

class NodeStairsNorth extends NodeSlopeNorth {
  @override
  int get type => NodeType.Stairs_North;
}

class NodeStairsEast extends NodeSlopeEast {
  @override
  int get type => NodeType.Stairs_East;
}

class NodeStairsSouth extends NodeSlopeSouth {
  @override
  int get type => NodeType.Stairs_South;
}

class NodeStairsWest extends NodeSlopeWest {
  @override
  int get type => NodeType.Stairs_West;
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

  }
}

class NodeTorch extends NodeRadial {
  @override
  int get type => NodeType.Torch;

  @override
  double get radius => 0.2;
}

class NodeTreeBottom extends NodeRadial {
  @override
  int get type => NodeType.Tree_Bottom;

  @override
  double get radius => 0.2;
}

class NodeTreeTop extends Node {
  @override
  int get type => NodeType.Tree_Top;

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

class NodeGrassLong extends NodeNoneCollidable {
  @override
  int get type => NodeType.Grass_Long;
}

class NodeWood extends NodeSolid {
  @override
  int get type => NodeType.Wood;
}

class NodeFireplace extends NodeRadial {
  @override
  int get type => NodeType.Fireplace;

  @override
  double get radius => 0.4;
}

class NodeGrassSlopeNorth extends NodeSlopeNorth {
  @override
  int get type => NodeType.Grass_Slope_North;
}

class NodeGrassSlopeEast extends NodeSlopeEast {
  @override
  int get type => NodeType.Grass_Slope_East;
}

class NodeGrassSlopeSouth extends NodeSlopeSouth {
  @override
  int get type => NodeType.Grass_Slope_South;
}

class NodeGrassSlopeWest extends NodeSlopeWest {
  @override
  int get type => NodeType.Grass_Slope_West;
}

class NodeBrickTop extends Node {
  @override
  int get type => NodeType.Brick_Top;

  @override
  bool getCollision(double x, double y, double z) {
    return y % tileHeight > tileHeightHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
      character.z += tileHeight - (character.z % tileHeight);
      character.zVelocity = 0;
  }
}

class NodeWoodHalfRow1 extends Node {
  @override
  int get type => NodeType.Wood_Half_Row_1;

  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) > tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {

  }
}

class NodeWoodHalfRow2 extends Node {
  @override
  int get type => NodeType.Wood_Half_Row_2;

  @override
  bool getCollision(double x, double y, double z) {
    return (y % tileSize) < tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
  }
}

class NodeWoodHalfColumn1 extends Node {
  @override
  int get type => NodeType.Wood_Half_Column_1;

  @override
  bool getCollision(double x, double y, double z) {
    return (x % tileSize) > tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
  }
}


class NodeWoodHalfColumn2 extends Node {
  @override
  int get type => NodeType.Wood_Half_Column_2;

  @override
  bool getCollision(double x, double y, double z) {
    return (x % tileSize) < tileSizeHalf;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
  }
}

class NodeRoofTileNorth extends NodeSlopeNorth {
  @override
  int get type => NodeType.Roof_Tile_North;
}

class NodeRoofTileSouth extends NodeSlopeSouth {
  @override
  int get type => NodeType.Roof_Tile_South;
}

class NodeSoil extends NodeSolid {
  @override
  int get type => NodeType.Soil;
}

class NodeRoofHayNorth extends NodeSlopeNorth {
  @override
  int get type => NodeType.Roof_Hay_North;
}

class NodeRoofHaySouth extends NodeSlopeSouth {
  @override
  int get type => NodeType.Roof_Hay_South;
}

class NodeStone extends NodeSolid {
  @override
  int get type => NodeType.Stone;
}

class NodeGrassSlopeTop extends NodeSlope {

  @override
  int get type => NodeType.Grass_Slope_Top;

  @override
  double getGradient(double x, double y) {
      final total = x + y;
      if (total < 1) return 0;
      return total - 1.0;
  }
}

class NodeGrassSlopeRight extends NodeSlope {

  @override
  int get type => NodeType.Grass_Slope_Right;

  @override
  double getGradient(double x, double y) {
      final ratio = (y - x);
      if (ratio < 0) return 0;
      return ratio;
  }
}

class NodeGrassSlopeBottom extends NodeSlope {

  @override
  int get type => NodeType.Grass_Slope_Bottom;

  @override
  double getGradient(double x, double y) {
      final total = x + y;
      if (total > 1) return 0;
      return 1.0 - total;
  }
}

class NodeGrassSlopeLeft extends NodeSlope {
  @override
  int get type => NodeType.Grass_Slope_Left;

  @override
  double getGradient(double x, double y) {
      final tX = (x - y);
      if (tX < 0) return 0;
      return tX;
  }
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
  int get type => NodeType.Wood_Corner_Top;
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
  int get type => NodeType.Wood_Corner_Right;
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
  int get type => NodeType.Wood_Corner_Bottom;
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
  int get type => NodeType.Wood_Corner_Left;
}


class NodeGrassEdgeTop extends NodeSlope {

  @override
  double getGradient(double x, double y) {
      final total = x + y;
      if (total > 1) return 1;
      return total;
  }

  @override
  int get type => NodeType.Grass_Edge_Top;
}

class NodeGrassEdgeRight extends NodeSlope {

  @override
  double getGradient(double x, double y) {
      final tX = (x - y);
      if (tX < 0) return 1;
      return 1 - tX;
  }

  @override
  int get type => NodeType.Grass_Edge_Right;
}

class NodeGrassEdgeBottom extends NodeSlope {

  @override
  double getGradient(double x, double y) {
      final total = x + y;
      if (total < 1) return 1;
      return 1 - (total - 1);
  }

  @override
  int get type => NodeType.Grass_Edge_Bottom;
}

class NodeGrassEdgeLeft extends NodeSlope {

  @override
  double getGradient(double x, double y) {
      final tX = (x - y);
      if (tX > 0) return 1;
      return 1 + tX;
  }

  @override
  int get type => NodeType.Grass_Edge_Left;
}

class NodeBauHaus extends NodeSolid {
  @override
  int get type => NodeType.Bau_Haus;
}

class NodeBauHausRoofNorth extends NodeSlopeNorth {
  @override
  int get type => NodeType.Bau_Haus_Roof_North;
}

class NodeBauHausRoofSouth extends NodeSlopeSouth {
  @override
  int get type => NodeType.Bau_Haus_Roof_South;
}

class NodeBauHausWindow extends NodeSolid {
  @override
  int get type => NodeType.Bau_Haus_Window;
}

class NodeBauHausPlain extends NodeSolid {
  @override
  int get type => NodeType.Bau_Haus_Plain;
}

class NodeChimney extends NodeSolid {
  @override
  int get type => NodeType.Chimney;
}

class NodeBedBottom extends NodeSolid {
  @override
  int get type => NodeType.Bed_Bottom;
}

class NodeBedTop extends NodeSolid {
  @override
  int get type => NodeType.Bed_Top;
}

class NodeTable extends NodeSolid {
  @override
  int get type => NodeType.Table;
}

class NodeOven extends NodeSolid {
  @override
  int get type => NodeType.Oven;
}

class NodeSunflower extends Node {
  @override
  int get type => NodeType.Sunflower;

  @override
  bool getCollision(double x, double y, double z) => false;

  @override
  void resolveCharacterCollision(Character character, Game game) {

  }
}