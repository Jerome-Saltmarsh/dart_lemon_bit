import 'dart:typed_data';

import '../common/library.dart';
import '../common/node_orientation.dart';
import '../common/node_size.dart';
import 'ai.dart';
import 'character.dart';
import 'game.dart';
import 'gameobject.dart';
import 'node.dart';

class Scene {
  late Uint8List nodeTypes;
  late Uint8List nodeOrientations;

  var gridHeight = 0;
  var gridRows = 0;
  var gridColumns = 0;
  var gridVolume = 0;
  var gridArea = 0;
  var name = "";
  var dirty = false;
  final List<GameObject> gameObjects;

  late double gridRowLength;
  late double gridColumnLength;
  late double gridHeightLength;

  Scene({
    required this.name,
    required this.nodeTypes,
    required this.nodeOrientations,
    required this.gridHeight,
    required this.gridRows,
    required this.gridColumns,
    required this.gameObjects,
  }) {
    refreshGridMetrics();
  }

  void refreshGridMetrics(){
    gridArea = gridRows * gridColumns;
    gridVolume = gridHeight * gridArea;
    gridRowLength = gridRows * tileSize;
    gridColumnLength = gridColumns * tileSize;
    gridHeightLength = gridHeight * nodeHeight;
  }

  int getGridType(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? NodeType.Boundary
          : nodeTypes[getNodeIndex(z, row, column)];

  int getGridOrientation(int z, int row, int column) =>
      outOfBounds(z, row, column)
          ? NodeType.Boundary
          : nodeOrientations[getNodeIndex(z, row, column)];


  int getNodeIndex(int z, int row, int column) {
    assert (!outOfBounds(z, row, column));
    return (z * gridArea) + (row * gridColumns) + column;
  }

  bool outOfBounds(int z, int row, int column){
     if (z < 0) return true;
     if (row < 0) return true;
     if (column < 0) return true;
     if (z >= gridHeight) return true;
     if (row >= gridRows) return true;
     if (column >= gridColumns) return true;
     return false;
  }

  void setNode(int z, int row, int column, int type, int orientation) {
    if (outOfBounds(z, row, column)) return;
    final index = getNodeIndex(z, row, column);
    final currentType = nodeTypes[index];
    final currentOrientation = nodeOrientations[index];
    if (currentType == type && currentOrientation == orientation) {
      return;
    }
    dirty = true;
    nodeTypes[index] = type;
    nodeOrientations[index] = orientation;
  }

  int getNodeTypeXYZ(double x, double y, double z) =>
      getNodeInBoundsXYZ(x, y, z)
          ? nodeTypes[getNodeIndexXYZ(x, y, z)]
          : NodeType.Boundary;

  int getNodeIndexXYZ(double x, double y, double z) =>
    getNodeIndex(
        z ~/ tileSizeHalf,
        x ~/ tileSize,
        y ~/ tileSize,
    );

  int getNodeOrientationXYZ(double x, double y, double z) =>
      getNodeInBoundsXYZ(x, y, z)
          ? NodeOrientation.None
          : nodeOrientations[getNodeIndexXYZ(x, y, z)];

  bool getNodeInBoundsXYZ(double x, double y, double z) =>
    z >= 0 &&
    x >= 0 &&
    y >= 0 &&
    z < gridHeightLength &&
    x < gridRowLength &&
    y < gridColumnLength;

  // bool visitDirection(int direction, Node from) {
  //   if (direction == Direction.North_West && !from.up.open && !from.left.open) return false;
  //   if (direction == Direction.South_West && !from.down.open && !from.left.open) return false;
  //   if (direction == Direction.South_East && !from.down.open && !from.right.open) return false;
  //   if (direction == Direction.North_East && !from.up.open && !from.right.open) return false;
  //   return visitNode(from.getNodeByDirection(direction), from);
  // }

  // bool visitNodeFirst(Node node){
  //   node.depth = 0;
  //   node.previous = null;
  //   node.searchId = pathFindSearchID;
  //
  //   if (!node.open) {
  //     return false;
  //   }
  //
  //   if (node.depth == 50 || node == pathFindDestination) {
  //     var current = node.previous;
  //     final pathX = pathFindAI.pathX;
  //     final pathY = pathFindAI.pathY;
  //     var index = 0;
  //     while (current != null) {
  //       pathX[index] = current.x;
  //       pathY[index] = current.y;
  //       current = current.previous;
  //       index++;
  //     }
  //     pathFindAI.pathIndex = index - 2;
  //     return true;
  //   }
  //
  //   final direction = parseRowsAndColumnsToDirection(
  //     pathFindDestination.row - node.row,
  //     pathFindDestination.column - node.column,
  //   );
  //   node.reserveSurroundingNodes();
  //
  //   if (visitDirection(direction, node)) return true;
  //
  //   final directionIndex = direction;
  //
  //   for (var i = 1; i < 4; i++) {
  //     final leftDirection = clampDirection(directionIndex - i);
  //     if (visitDirection(leftDirection, node)) {
  //       return true;
  //     }
  //     final rightDirection = clampDirection(directionIndex + i);
  //     if (visitDirection(rightDirection, node)) {
  //       return true;
  //     }
  //   }
  //
  //   final directionBehind = clampDirection(directionIndex + 4);
  //   return visitDirection(directionBehind, node);
  // }

  // bool visitNode(Node node, Node previous) {
  //   if (!node.visitable) return false;
  //
  //   if (node.reserveId == pathFindSearchID){
  //     if (node.reserved != previous){
  //       return visitNode(node, node.reserved!);
  //     }
  //   }
  //
  //   node.depth = previous.depth + 1;
  //
  //   node.previous = previous;
  //   node.searchId = pathFindSearchID;
  //
  //   if (node.depth == 60 || node == pathFindDestination) {
  //     var current = node.previous;
  //     final pathX = pathFindAI.pathX;
  //     final pathY = pathFindAI.pathY;
  //     var index = 0;
  //     while (current != null) {
  //       pathX[index] = current.x;
  //       pathY[index] = current.y;
  //       current = current.previous;
  //       index++;
  //     }
  //     pathFindAI.pathIndex = index - 2;
  //     return true;
  //   }
  //
  //   final direction = parseRowsAndColumnsToDirection(
  //     pathFindDestination.row - node.row,
  //     pathFindDestination.column - node.column,
  //   );
  //   node.reserveSurroundingNodes();
  //
  //   if (visitDirection(direction, node)) return true;
  //
  //   final directionIndex = direction;
  //
  //   for (var i = 1; i < 4; i++) {
  //     final leftDirection = clampDirection(directionIndex - i);
  //     if (visitDirection(leftDirection, node)) {
  //       return true;
  //     }
  //     final rightDirection = clampDirection(directionIndex + i);
  //     if (visitDirection(rightDirection, node)) {
  //       return true;
  //     }
  //   }
  //
  //   final directionBehind = clampDirection(directionIndex + 4);
  //   return visitDirection(directionBehind, node);
  // }

  bool getCollisionAt(double x, double y, double z) {
     if (x < 0) return true;
     if (y < 0) return true;
     if (z < 0) return false;
     if (x > gridRowLength) return true;
     if (y > gridColumnLength) return true;
     if (z > gridHeightLength) return false;
     return getNodeOrientationXYZ(x, y, z) != NodeOrientation.None;
  }

  void resolveCharacterTileCollision(Character character, Game game) {
    character.z -= character.zVelocity;
    character.zVelocity += 0.98;

    const distance = 3;
    final stepHeight = character.z + tileHeightHalf;

    if (getCollisionAt(character.left, character.top, stepHeight)) {
      character.x += distance;
      character.y += distance;
    }
    else
    if (getCollisionAt(character.right, character.bottom, stepHeight)) {
      character.x -= distance;
      character.y -= distance;
    }
    if (getCollisionAt(character.left, character.bottom, stepHeight)) {
      character.x += distance;
      character.y -= distance;
    } else
    if (getCollisionAt(character.right, character.top, stepHeight)) {
      character.x -= distance;
      character.y += distance;
    }


    if (getNodeInBoundsXYZ(character.x, character.y, character.z)) {
      final nodeAtFeetIndex = getNodeIndexXYZ(character.x, character.y, character.z);
      final nodeAtFeetOrientation = nodeOrientations[nodeAtFeetIndex];

      if (nodeAtFeetOrientation != NodeOrientation.None) {
        final bottom = (character.z ~/ tileHeight) * tileHeight;
        final percX = ((character.x % tileSize) / tileSize);
        final percY = ((character.y % tileSize) / tileSize);
        final nodeTop = bottom + (getOrientationGradient(nodeAtFeetOrientation, percX, percY) * nodeHeight);
        if (nodeTop > character.z){
          character.z = nodeTop;
          character.zVelocity = 0;
        }
      }
    } else {
      if (character.z < -100){
        game.setCharacterStateDead(character);
      }
    }
  }
  //
  // double getHeight(double x, double y, double z) {
  //   final bottom = (z ~/ tileHeight) * tileHeight;
  //   final percX = ((x % tileSize) / tileSize);
  //   final percY = ((y % tileSize) / tileSize);
  //   assert (percX >= 0 && percX <= 1);
  //   assert (percY >= 0 && percY <= 1);
  //   return bottom + (getGradient(percX, percY) * tileHeight);
  // }
}

late AI pathFindAI;
late Node pathFindDestination;
var pathFindSearchID = 0;


int parseRowsAndColumnsToDirection(int rows, int columns) {
  assert(rows != 0 || columns != 0);
  if (rows > 0) {
     if (columns < 0) return Direction.South_West;
     if (columns == 0) return Direction.South;
     return Direction.South_East;
  }
  if (rows < 0) {
    if (columns < 0) return Direction.North_West;
    if (columns == 0) return Direction.North;
    return Direction.North_East;
  }
  if (columns < 0) return Direction.West;
  return Direction.East;
}


/// Returns a value between 0 and 1 which indicates the height of this given position
/// Arguments percX and percY are both values between 0 and 1 representing the relative position on the tile
double getOrientationGradient(int orientation, double x, double y) {
  switch (orientation) {
    case NodeOrientation.Solid:
      return 1;
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