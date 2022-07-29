import '../common/library.dart';
import 'ai.dart';
import 'character.dart';
import 'enemy_spawn.dart';
import 'game.dart';
import 'tile_node.dart';

class Scene {
  final List<List<List<int>>> grid;

  var gridHeight = 0;
  var gridRows = 0;
  var gridColumns = 0;
  var name = "";
  var dirty = false;
  final List<Character> characters;
  final List<EnemySpawn> enemySpawns;

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
     return grid[z][row][column];
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

  void gridForeach({
    required bool Function(int type) where,
    required Function(int z, int row, int column, int type) apply,
}){
    for (var zIndex = 0; zIndex < gridHeight; zIndex++) {
      final zValues = grid[zIndex];
      for (var rowIndex = 0; rowIndex < gridRows; rowIndex++) {
        final rowValues = zValues[rowIndex];
        for (var columnIndex = 0; columnIndex < gridColumns; columnIndex++) {
          final t = rowValues[columnIndex];
          if (!where(t)) continue;
          apply(zIndex, rowIndex, columnIndex, t);
        }
      }
    }
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

  int getGridBlockTypeAtXYZ(double x, double y, double z){
    if (z < 0) return GridNodeType.Boundary;
    if (x < 0) return GridNodeType.Boundary;
    if (y < 0) return GridNodeType.Boundary;
    final row = x ~/ tileSize;
    if (row >= gridRows) return GridNodeType.Boundary;
    final column = y ~/ tileSize;
    if (column >= gridColumns) return GridNodeType.Boundary;
    final height = z ~/ tileSizeHalf;
    if (height >= gridHeight) return GridNodeType.Empty;
    return grid[height][row][column];
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

  double getHeightAt(double x, double y, double z){
    var type = getGridBlockTypeAtXYZ(x, y, z);
    final bottom = (z ~/ tileHeight) * tileHeight;
    if (type == GridNodeType.Empty) return bottom;
    if (type == GridNodeType.Boundary) return bottom;
    if (type == GridNodeType.Bricks) return bottom;

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
    var type = getGridBlockTypeAtXYZ(x, y, z);
    if (type == GridNodeType.Empty) return false;
    if (GridNodeType.isSolid(type)) return true;

    if (type == GridNodeType.Brick_Top){
       return y % tileHeight > tileHeightHalf;
    }

    if (type == GridNodeType.Wood_Half_Row_1){
      return (y % tileSize) > tileSizeHalf;
    }

    if (type == GridNodeType.Wood_Half_Row_2){
      return (y % tileSize) <= tileSizeHalf;
    }

    if (type == GridNodeType.Wood_Half_Column_1){
      return (x % tileSize) > tileSizeHalf;
    }

    if (type == GridNodeType.Wood_Half_Column_2){
      return (x % tileSize) <= tileSizeHalf;
    }

    if (type == GridNodeType.Wood_Corner_Bottom){
      return (y % tileSize) > tileSizeHalf ||  (x % tileSize) > tileSizeHalf;
    }
    if (type == GridNodeType.Wood_Corner_Top){
      return (y % tileSize) < tileSizeHalf ||  (x % tileSize) < tileSizeHalf;
    }
    if (type == GridNodeType.Wood_Corner_Left){
      return (y % tileSize) > tileSizeHalf ||  (x % tileSize) < tileSizeHalf;
    }
    if (type == GridNodeType.Wood_Corner_Right){
      return (y % tileSize) < tileSizeHalf ||  (x % tileSize) > tileSizeHalf;
    }

    if (GridNodeType.isStairs(type)){
      return getHeightAt(x, y, z) > z;
    }
    if (type == GridNodeType.Tree_Bottom || type == GridNodeType.Torch){
      const treeRadius = 0.2;
      final percRow = (x / 48.0) % 1.0;
      if ((0.5 - percRow).abs() > treeRadius) return false;
      final percColumn = (y / 48.0) % 1.0;
      if ((0.5 - percColumn).abs() > treeRadius) return false;
      return true;
    }
    if (type == GridNodeType.Fireplace){
      const treeRadius = 0.8;
      final percRow = (x / 48.0) % 1.0;
      if ((0.5 - percRow).abs() > treeRadius) return false;
      final percColumn = (y / 48.0) % 1.0;
      if ((0.5 - percColumn).abs() > treeRadius) return false;
      return true;
    }
    return false;
  }

  void resolveCharacterTileCollision(Character character, Game game) {
    character.z -= character.zVelocity;
    character.zVelocity += 0.98;

    if (character.z <= 0) {
      character.z = 0;
      character.zVelocity = 0;
    }

    var tileAtFeet = getGridBlockTypeAtXYZ(character.x, character.y, character.z);

    if (GridNodeType.isWater(tileAtFeet)) {
       game.dispatchV3(GameEventType.Splash, character);
       game.setCharacterStateDead(character);
       return;
    }

    if (GridNodeType.isSolid(tileAtFeet)) {
       character.z += 24 - (character.z % 24);
       character.zVelocity = 0;
    } else
    if (GridNodeType.isStairs(tileAtFeet)){
      character.z = getHeightAt(character.x, character.y, character.z);
      character.zVelocity = 0;
    } else
    if (tileAtFeet == GridNodeType.Brick_Top){
      character.z += 24 - (character.z % 24);
      character.zVelocity = 0;
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

void repairScene(Scene scene){
  scene.gridForeach(
      where: ((type) => type == GridNodeType.Tree_Bottom),
      apply: (int z, int row, int column, int type){
          if (z + 1 < tileHeight){
            scene.grid[z + 1][row][column] = GridNodeType.Tree_Top;
          }
      }
  );
}
