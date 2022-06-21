import 'package:lemon_math/library.dart';
import '../common/grid_node_type.dart';
import '../common/library.dart';
import 'AI.dart';
import 'Character.dart';
import 'enemy_spawn.dart';
import 'game_object.dart';
import 'TileNode.dart';
import 'grid_index.dart';
import 'grid_node.dart';

class Scene {
  final List<List<List<GridNode>>> grid;
  final List<Character> characters;
  final List<GameObject> gameObjects;
  final List<EnemySpawn> enemySpawns;

  int? startHour;
  int? secondsPerFrames;

  int get gridHeight => grid.length;
  int get gridRows => grid[0].length;
  int get gridColumns => grid[0][0].length;

  Scene({
    required this.gameObjects,
    required this.characters,
    required this.grid,
    required this.enemySpawns,
  }) {
    sortVertically(gameObjects);
  }

  GridIndex? findGridByType(int type){
      for (var z = 0; z < gridHeight; z++) {
         for (var row = 0; row < gridRows; row++){
            for (var column = 0; column < gridColumns; column++){
               if (grid[z][row][column].type != type) continue;
               gridIndex.plain = z;
               gridIndex.row = row;
               gridIndex.column = column;
               return gridIndex;
            }
         }
      }
      return null;
  }

  List<GridNode> findNodesByType(int type){
    final values = <GridNode>[];
    final height = gridHeight;
    final rows = gridRows;
    final columns = gridColumns;
    for (var z = 0; z < height; z++) {
      final plain = grid[z];
      for (var r = 0; r < rows; r++) {
        final row = plain[r];
        for (var c = 0; c < columns; c++) {
          if (row[c].type != type) continue;
          values.add(row[c]);
        }
      }
    }
    return values;
  }

  void addGameObjectAtNode({
    required int type,
    required Node node,
    int health = 1
  }){
    addGameObject(
        GameObject(
          type: type,
          x: 0,
          y: 0,
          // x: getTilePositionX(node.row, node.column),
          // y: getTilePositionY(node.row, node.column),
          health: health,
        )
    );
  }

  void addGameObjectPosition({
    required int type,
    required Position position,
    int health = 1
  }) {
    addGameObjectAtXY(
      type: type,
      x: position.x,
      y: position.y,
      health: health,
    );
  }

  void addGameObjectAtXY({
    required int type,
    required double x,
    required double y,
    int health = 1
  }) {
    addGameObject(
        GameObject(
          type: type,
          x: x,
          y: y,
          health: health,
        )
    );
  }

  void addGameObject(GameObject value) {
    gameObjects.add(value);
    sortGameObjects();
  }

  void sortGameObjects(){
    sortVertically(gameObjects);
  }

  int getGridBlockTypeAtXYZ(double x, double y, double z){
    if (z < 0) return GridNodeType.Boundary;
    if (x < 0) return GridNodeType.Boundary;
    if (y < 0) return GridNodeType.Boundary;
    final row = x ~/ tileSize;
    if (row >= grid[0].length) return GridNodeType.Boundary;
    final column = y ~/ tileSize;
    if (column >= grid[0][0].length) return GridNodeType.Boundary;
    final height = z ~/ tileSizeHalf;
    if (height >= grid.length) return GridNodeType.Empty;
    return grid[height][row][column].type;
  }

  bool visitDirection(int direction, Node from) {
    if (direction == Direction.North_West && !from.up.open && !from.left.open) return false;
    if (direction == Direction.South_West && !from.down.open && !from.left.open) return false;
    if (direction == Direction.South_East && !from.down.open && !from.right.open) return false;
    if (direction == Direction.North_East && !from.up.open && !from.right.open) return false;
    return visitNode(from.getNodeByDirection(direction), from);
  }

  bool visitNodeFirst(Node node){
    node.depth = 0;
    node.previous = null;
    node.searchId = pathFindSearchID;

    if (!node.open) {
      return false;
    }

    if (node.depth == 50 || node == pathFindDestination) {
      var current = node.previous;
      final pathX = pathFindAI.pathX;
      final pathY = pathFindAI.pathY;
      var index = 0;
      while (current != null) {
        pathX[index] = current.x;
        pathY[index] = current.y;
        current = current.previous;
        index++;
      }
      pathFindAI.pathIndex = index - 2;
      return true;
    }

    final direction = parseRowsAndColumnsToDirection(
      pathFindDestination.row - node.row,
      pathFindDestination.column - node.column,
    );
    node.reserveSurroundingNodes();

    if (visitDirection(direction, node)) return true;

    final directionIndex = direction;

    for (var i = 1; i < 4; i++) {
      final leftDirection = clampDirection(directionIndex - i);
      if (visitDirection(leftDirection, node)) {
        return true;
      }
      final rightDirection = clampDirection(directionIndex + i);
      if (visitDirection(rightDirection, node)) {
        return true;
      }
    }

    final directionBehind = clampDirection(directionIndex + 4);
    return visitDirection(directionBehind, node);
  }

  bool visitNode(Node node, Node previous) {
    if (!node.visitable) return false;

    if (node.reserveId == pathFindSearchID){
      if (node.reserved != previous){
        return visitNode(node, node.reserved!);
      }
    }

    node.depth = previous.depth + 1;

    node.previous = previous;
    node.searchId = pathFindSearchID;

    if (node.depth == 60 || node == pathFindDestination) {
      var current = node.previous;
      final pathX = pathFindAI.pathX;
      final pathY = pathFindAI.pathY;
      var index = 0;
      while (current != null) {
        pathX[index] = current.x;
        pathY[index] = current.y;
        current = current.previous;
        index++;
      }
      pathFindAI.pathIndex = index - 2;
      return true;
    }

    final direction = parseRowsAndColumnsToDirection(
      pathFindDestination.row - node.row,
      pathFindDestination.column - node.column,
    );
    node.reserveSurroundingNodes();

    if (visitDirection(direction, node)) return true;

    final directionIndex = direction;

    for (var i = 1; i < 4; i++) {
      final leftDirection = clampDirection(directionIndex - i);
      if (visitDirection(leftDirection, node)) {
        return true;
      }
      final rightDirection = clampDirection(directionIndex + i);
      if (visitDirection(rightDirection, node)) {
        return true;
      }
    }

    final directionBehind = clampDirection(directionIndex + 4);
    return visitDirection(directionBehind, node);
  }

  // bool tileWalkableAt(double x, double y){
  //   return getNodeByXY(x, y).open;
  // }

  GameObject? findNearestGameObjectByType({
    required double x,
    required double y,
    required int type
  }){
     var distance = 999999999.0;
     GameObject? nearest = null;
     for (final object in gameObjects ) {
        if (object.type != type) continue;
        final objectDistance = object.getDistanceXY(x, y);
        if (objectDistance > distance) continue;
        nearest = object;
        distance = objectDistance;
     }
     return nearest;
  }

  double getHeightAt(double x, double y, double z){
    var type = getGridBlockTypeAtXYZ(x, y, z);
    final bottom = (z ~/ tileHeight) * tileHeight;
    if (type == GridNodeType.Empty) return bottom;
    if (type == GridNodeType.Boundary) return bottom;
    if (type == GridNodeType.Bricks) return bottom;

    if (type == GridNodeType.Stairs_North){
      final percentage = 1 - ((x % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    if (type == GridNodeType.Stairs_South){
      final percentage = ((x % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    if (type == GridNodeType.Stairs_West){
      final percentage = ((y % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    if (type == GridNodeType.Stairs_East){
      final percentage = 1 - ((y % tileSize) / tileSize);
      return (percentage * tileHeight) + bottom;
    }
    return bottom + tileHeight;
  }

  bool getCollisionAt(double x, double y, double z) {
    var type = getGridBlockTypeAtXYZ(x, y, z);
    if (type == GridNodeType.Empty) return false;
    if (type == GridNodeType.Boundary) return true;
    if (type == GridNodeType.Bricks) return true;
    if (type == GridNodeType.Player_Spawn) return false;

    if (GridNodeType.isStairs(type)){
      return getHeightAt(x, y, z) > z;
    }
    if (type == GridNodeType.Tree_Bottom_Pine || type == GridNodeType.Torch){
      const treeRadius = 0.2;
      final percRow = (x / 48.0) % 1.0;
      if ((0.5 - percRow).abs() > treeRadius) return false;
      final percColumn = (y / 48.0) % 1.0;
      if ((0.5 - percColumn).abs() > treeRadius) return false;
      return true;
    }
    return true;
  }

  void resolveCharacterTileCollision(Character character) {
    character.z -= character.zVelocity;
    character.zVelocity += 0.98;

    if (character.z <= 0) {
      character.z = 0;
      character.zVelocity = 0;
    }

    var tileAtFeet = getGridBlockTypeAtXYZ(character.x, character.y, character.z);

    while (tileAtFeet == GridNodeType.Bricks || tileAtFeet == GridNodeType.Grass || tileAtFeet == GridNodeType.Grass_Long) {
       character.z += 24 - (character.z % 24);
       tileAtFeet = getGridBlockTypeAtXYZ(character.x, character.y, character.z);
       character.zVelocity = 0;
    }
    if (GridNodeType.isStairs(tileAtFeet)){
      character.z = getHeightAt(character.x, character.y, character.z);
      character.zVelocity = 0;
    }
    const distance = 3;
    final stepHeight = character.z + 15;

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
