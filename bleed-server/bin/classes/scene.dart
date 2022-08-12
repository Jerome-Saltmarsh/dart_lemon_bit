import '../common/library.dart';
import 'ai.dart';
import 'character.dart';
import 'enemy_spawn.dart';
import 'game.dart';
import 'node.dart';

class Scene {
  final List<List<List<Node>>> grid;

  var gridHeight = 0;
  var gridRows = 0;
  var gridColumns = 0;
  var name = "";
  var dirty = false;
  final List<Character> characters;
  final List<EnemySpawn> enemySpawns;

  double get gridRowLength => gridRows * tileSize;
  double get gridColumnLength => gridColumns * tileSize;

  int? startHour;
  int? secondsPerFrames;

  Scene({
    required this.name,
    required this.characters,
    required this.grid,
    required this.enemySpawns,
  }) {
    refreshGridMetrics();
  }

  int getGridType(int z, int row, int column){
     if (outOfBounds(z, row, column)) return GridNodeType.Boundary;
     return grid[z][row][column].type;
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

  void refreshGridMetrics(){
    gridHeight = grid.length;
    gridRows = grid[0].length;
    gridColumns = grid[0][0].length;
  }

  bool findByType(int type, void Function(int z, int row, int column) callback) {
     for (var zI = 0; zI < gridHeight; zI++){
       final z = grid[zI];
        for (var rowI = 0; rowI < gridRows; rowI++){
          final row = z[rowI];
           for (var columnI = 0; columnI < gridColumns; columnI++){
              if (row[columnI] != type) continue;
              callback(zI, rowI, columnI);
              return true;
           }
        }
     }
     return false;
  }

  Node getNodeXYZ(double x, double y, double z){
    if (z < 0) return Node.boundary;
    if (x < 0) return Node.boundary;
    if (y < 0) return Node.boundary;
    final row = x ~/ tileSize;
    if (row >= gridRows) return Node.boundary;
    final column = y ~/ tileSize;
    if (column >= gridColumns) return Node.boundary;
    final height = z ~/ tileSizeHalf;
    if (height >= gridHeight) return Node.boundary;
    return grid[height][row][column];
  }

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

  double getHeightAt(double x, double y, double z){
    var type = getNodeXYZ(x, y, z).type;
    final bottom = (z ~/ tileHeight) * tileHeight;
    if (type == GridNodeType.Empty) return bottom;
    if (type == GridNodeType.Boundary) return bottom;

    if (GridNodeType.isSlopeNorth(type)){
      final percentage = 1 - ((x % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    if (GridNodeType.isSlopeSouth(type)){
      final percentage = ((x % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    if (GridNodeType.isSlopeWest(type)){
      final percentage = ((y % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    if (GridNodeType.isSlopeEast(type)){
      final percentage = 1 - ((y % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    return bottom + tileHeight;
  }

  bool getCollisionAt(double x, double y, double z) {
    return getNodeXYZ(x, y, z).getCollision(x, y, z);
  }

  void resolveCharacterTileCollision(Character character, Game game) {
    character.z -= character.zVelocity;
    character.zVelocity += 0.98;

    var nodeAtFeet = getNodeXYZ(character.x, character.y, character.z);
    nodeAtFeet.resolveCharacterCollision(character, game);

    if (character.z < -100){
       game.setCharacterStateDead(character);
    }

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
  }
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

// double getTilePositionX(int row, int column){
//   return (column * halfTileSize) - (row * halfTileSize);
// }
//
// double getTilePositionY(int row, int column){
//   return (row * halfTileSize) + (column * halfTileSize) + halfTileSize;
// }
//

