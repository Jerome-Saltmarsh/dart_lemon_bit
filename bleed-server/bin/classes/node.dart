

import '../common/library.dart';
import '../common/node_orientation.dart';
import 'character.dart';
import 'game.dart';

abstract class Node {
  int get type;
  bool getCollision(double x, double y, double z);
  void resolveCharacterCollision(Character character, Game game);

  bool get isEmpty => type == NodeType.Empty;

  int get orientation => NodeOrientation.None;

  bool get isSlopeSymmetric => NodeOrientation.isSlopeSymmetric(orientation);
  bool get isCorner => NodeOrientation.isCorner(orientation);
  bool get isSolid => orientation == NodeOrientation.Solid;
  bool get isOriented => NodeType.isOriented(type);

  static final Node boundary = NodeBoundary();
  static final Node grassFlowers = NodeGrassFlowers();
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

class NodeGrassFlowers extends NodeSolid {
  @override
  int get type => NodeType.Grass_Flowers;
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

class NodeFireplace extends NodeRadial {
  @override
  int get type => NodeType.Fireplace;

  @override
  double get radius => 0.4;
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

class NodeBauHaus extends NodeSolid {
  @override
  int get type => NodeType.Bau_Haus;
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

class NodeOriented extends Node {

  late int _orientation;
  late int _type;

  @override
  int get type => _type;

  @override
  int get orientation => _orientation;

  set orientation(int value) => _orientation = value;

  NodeOriented({required int orientation, required int type}) {
    this._orientation = orientation;
    this._type = type;
  }

  @override
  bool getCollision(double x, double y, double z) {
    if (isSolid)
      return true;

    return getHeight(x, y, z) > z;
  }

  @override
  void resolveCharacterCollision(Character character, Game game) {
    character.z = getHeight(character.x, character.y, character.z);
    character.zVelocity = 0;
  }

  double getHeight(double x, double y, double z) {
    final bottom = (z ~/ tileHeight) * tileHeight;
    if (isSolid) return bottom + tileHeight;
    final percX = ((x % tileSize) / tileSize);
    final percY = ((y % tileSize) / tileSize);
    assert (percX >= 0 && percX <= 1);
    assert (percY >= 0 && percY <= 1);
    return bottom + (getGradient(percX, percY) * tileHeight);
  }

  /// Returns a value between 0 and 1 which indicates the height of this given position
  /// Arguments percX and percY are both values between 0 and 1 representing the relative position on the tile
  double getGradient(double x, double y) {
    switch (_orientation) {
      case NodeOrientation.Slope_North:
        return 1 - x;
      case NodeOrientation.Slope_East:
        return 1 - y;
      case NodeOrientation.Slope_South:
        return x;
      case NodeOrientation.Slope_West:
        return y;
      case NodeOrientation.Corner_Top:
        if (x < 0.5) return 1.0;
        if (y < 0.5) return 1.0;
        return 0;
      case NodeOrientation.Corner_Right:
        if (x > 0.5) return 1.0;
        if (y < 0.5) return 1.0;
        return 0;
      case NodeOrientation.Corner_Bottom:
        if (x > 0.5) return 1.0;
        if (y > 0.5) return 1.0;
        return 0;
      case NodeOrientation.Corner_Left:
        if (x < 0.5) return 1.0;
        if (y > 0.5) return 1.0;
        return 0;
      case NodeOrientation.Half_North:
        if (x < 0.5) return 1.0;
        return 0;
      case NodeOrientation.Half_East:
        if (y < 0.5) return 1.0;
        return 0;
      case NodeOrientation.Half_South:
        if (x > 0.5) return 1.0;
        return 0;
      case NodeOrientation.Half_West:
        if (y > 0.5) return 1.0;
        return 0;
      case NodeOrientation.Slope_Inner_North_East: // Grass Edge Bottom
        final total = x + y;
        if (total < 1) return 1;
        return 1 - (total - 1); 
      case NodeOrientation.Slope_Inner_South_East: // Grass Edge Left
        final tX = (x - y);
        if (tX > 0) return 1;
        return 1 + tX; 
      case NodeOrientation.Slope_Inner_South_West: // Grass Edge Top
        final total = x + y;
        if (total > 1) return 1;
        return total; 
      case NodeOrientation.Slope_Inner_North_West: // Grass Edge Right
        final tX = (x - y);
        if (tX < 0) return 1;
        return 1 - tX; 
      case NodeOrientation.Slope_Outer_North_East: // Grass Slope Top
        final total = x + y;
        if (total > 1) return 0;
        return 1.0 - total;
      case NodeOrientation.Slope_Outer_South_East: // Grass Slope Left
        final tX = (x - y);
        if (tX < 0) return 0;
        return tX;
      case NodeOrientation.Slope_Outer_South_West: // Grass Slope Bottom
        final total = x + y;
        if (total < 1) return 0;
        return total - 1;
      case NodeOrientation.Slope_Outer_North_West: // Grass Slope Right
        final ratio = (y - x);
        if (ratio < 0) return 0;
        return ratio;
      default:
        throw Exception(
            "Sloped orientation type required to calculate gradient");
    }
  }
}
