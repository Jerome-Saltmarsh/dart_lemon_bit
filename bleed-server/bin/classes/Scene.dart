import 'package:lemon_math/library.dart';
import '../common/library.dart';
import '../enums.dart';
import '../utilities.dart';
import 'AI.dart';
import 'Character.dart';
import 'DynamicObject.dart';
import 'EnvironmentObject.dart';
import 'Structure.dart';
import 'TileNode.dart';

class Scene {
  final List<Structure> structures;
  final List<Character> characters;
  final List<List<int>> tiles;
  final List<StaticObject> objectsStatic;
  final List<DynamicObject> objectsDynamic;
  final List<Position> spawnPointPlayers;
  final List<Position> spawnPointZombies;

  late final List<List<Node>> nodes;
  late final int numberOfRows;
  late final int numberOfColumns;

  int? startHour;
  int? secondsPerFrames;

  static final _boundary = Node(false);

  int get rows => tiles.length;
  int get columns => rows > 0 ? tiles[0].length : 0;

  Scene({
    required this.tiles,
    required this.structures,
    required this.objectsStatic,
    required this.objectsDynamic,
    required this.characters,
    required this.spawnPointPlayers,
    required this.spawnPointZombies,
  }) {
    numberOfRows = tiles.length;
    numberOfColumns = numberOfRows > 0 ? tiles[0].length : 0;
    nodes = [];

    for (var rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
      final List<Node> nodeRow = [];
      final tileRow = tiles[rowIndex];
      for (var columnIndex = 0; columnIndex < numberOfColumns; columnIndex++) {
        final node = Node(isWalkable(tileRow[columnIndex]));
        node.row = rowIndex;
        node.column = columnIndex;
        node.x = getTilePositionX(node.row, node.column);
        node.y = getTilePositionY(node.row, node.column);
        nodeRow.add(node);
      }
      nodes.add(nodeRow);
    }

    for (var rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
      final tileNodeRow = nodes[rowIndex];
      final canUp = rowIndex > 0;
      final canDown = rowIndex < numberOfRows - 1;
      for (var columnIndex = 0; columnIndex < numberOfColumns; columnIndex++) {
        final tileNode = tileNodeRow[columnIndex];
        final canLeft = columnIndex > 0;
        final canRight = columnIndex < numberOfColumns - 1;

        if (canUp) {
          tileNode.up = nodes[rowIndex - 1][columnIndex];
          if (canLeft) {
            tileNode.upLeft = nodes[rowIndex - 1][columnIndex - 1];
          } else {
            tileNode.upLeft = _boundary;
          }
          if (canRight) {
            tileNode.upRight = nodes[rowIndex - 1][columnIndex + 1];
          } else {
            tileNode.upRight = _boundary;
          }
        } else {
          tileNode.up = _boundary;
          tileNode.upRight = _boundary;
          tileNode.upLeft = _boundary;
        }

        if (canDown) {
          tileNode.down = nodes[rowIndex + 1][columnIndex];

          if (canRight) {
            tileNode.downRight = nodes[rowIndex + 1][columnIndex + 1];
          } else {
            tileNode.downRight = _boundary;
          }

          if (canLeft) {
            tileNode.downLeft = nodes[rowIndex + 1][columnIndex - 1];
          } else {
            tileNode.downLeft = _boundary;
          }
        } else {
          tileNode.down = _boundary;
          tileNode.downRight = _boundary;
          tileNode.downLeft = _boundary;
        }

        if (canLeft) {
          tileNode.left = tileNodeRow[columnIndex - 1];
        } else {
          tileNode.left = _boundary;
        }

        if (canRight) {
          tileNode.right = tileNodeRow[columnIndex + 1];
        } else {
          tileNode.right = _boundary;
        }
      }
    }

    for (final env in objectsStatic) {
       snapToGrid(env);
       getNodeByPosition(env).obstructed = true;
    }

    for (var i = 0; i < objectsStatic.length; i++) {
       final env = objectsStatic[i];
       if (env.type == ObjectType.Rock) {
          objectsStatic.removeAt(i);
          i--;
          objectsDynamic.add(
              DynamicObject(
                  type: DynamicObjectType.Rock,
                  x: env.x,
                  y: env.y,
                  health: 50
              )
          );
       }
       if (env.type == ObjectType.Tree01) {
         objectsStatic.removeAt(i);
         i--;
         objectsDynamic.add(
             DynamicObject(
                 type: DynamicObjectType.Tree,
                 x: env.x,
                 y: env.y,
                 health: 10
             )
         );
       }
    }

    for (final staticObject in objectsStatic) {
       getNodeByPosition(staticObject).obstructed = true;
    }

    for (final dynamicObject in objectsDynamic) {
      getNodeByPosition(dynamicObject).obstructed = true;
    }

    sortVertically(objectsDynamic);
    sortVertically(objectsStatic);
  }

  void addObjectStatic(StaticObject value) {
    objectsStatic.add(value);
    getNodeByPosition(value).obstructed = true;
    sortVertically(objectsStatic);
  }

  int getTileAtPosition(Position position){
    return getTileAtXY(position.x, position.y);
  }

  int getTileAtXY(double x, double y) {
    const tileSize = 48;
    return getTileAtRowColumn(
        row: (x + y) ~/ tileSize,
        column: (y - x) ~/ tileSize
    );
  }

  int getTileAtRowColumn({required int row, required int column}){
    if (row < 0) return boundary;
    if (column < 0) return boundary;
    if (row >= numberOfRows) return boundary;
    if (column >= numberOfColumns) return boundary;
    return tiles[row][column];
  }


  bool visitDirection(int direction, Node from) {
    if (direction == Direction.UpLeft && !from.up.open && !from.left.open) return false;
    if (direction == Direction.DownLeft && !from.down.open && !from.left.open) return false;
    if (direction == Direction.DownRight && !from.down.open && !from.right.open) return false;
    if (direction == Direction.UpRight && !from.up.open && !from.right.open) return false;
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
      final leftDirection = sanitizeDirectionIndex(directionIndex - i);
      if (visitDirection(leftDirection, node)) {
        return true;
      }
      final rightDirection = sanitizeDirectionIndex(directionIndex + i);
      if (visitDirection(rightDirection, node)) {
        return true;
      }
    }

    final directionBehind = sanitizeDirectionIndex(directionIndex + 4);
    return visitDirection(directionBehind, node);
  }

  bool visitNode(Node node, Node previous) {
    if (!node.open) return false;
    if (node.obstructed) return false;

    if (node.searchId == pathFindSearchID) {
      return false;
    }

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
      final leftDirection = sanitizeDirectionIndex(directionIndex - i);
      if (visitDirection(leftDirection, node)) {
        return true;
      }
      final rightDirection = sanitizeDirectionIndex(directionIndex + i);
      if (visitDirection(rightDirection, node)) {
        return true;
      }
    }

    final directionBehind = sanitizeDirectionIndex(directionIndex + 4);
    return visitDirection(directionBehind, node);
  }

  bool waterAt(double x, double y) {
    return getTileAtXY(x, y) == Tile.Water;
  }

  bool tileWalkableAt(double x, double y){
    return getNodeByXY(x, y).open;
  }

  StaticObject? findNearestStaticObjectByType({
    required double x,
    required double y,
    required ObjectType type
  }){
     var distance = 999999999.0;
     StaticObject? nearest = null;
     for (final object in objectsStatic ) {
        if (object.type != type) continue;
        final objectDistance = object.getDistanceXY(x, y);
        if (objectDistance > distance) continue;
        nearest = object;
        distance = objectDistance;
     }
     return nearest;
  }

  Node getRandomNodeByTileType(int type){
     while(true){
        final node = getRandomTileNode();
        if (getTileAtPosition(node) != type) continue;
        return node;
     }
  }

  Node getRandomTileNode() {
    return getNodeByRowColumn(
        row: randomInt(0, rows),
        column: randomInt(0, columns)
    );
  }

  Node getNodeByPosition(Position position) {
    return getNodeByXY(position.x, position.y);
  }

  Node getNodeByXY(double x, double y) {
    const tileSize = 48;
    return getNodeByRowColumn(
        row: (x + y) ~/ tileSize,
        column: (y - x) ~/ tileSize
    );
  }

  Node getNodeByRowColumn({required int row, required int column}){
    if (row < 0) return _boundary;
    if (column < 0) return _boundary;
    if (row >= numberOfRows) return _boundary;
    if (column >= numberOfColumns) return _boundary;
    return nodes[row][column];
  }

  bool projectileCollisionAt(double x, double y) {
    return !isShootable(getTileAtXY(x, y));
  }

  void resolveCharacterTileCollision(Character character) {
    const distance = 3;
    if (!tileWalkableAt(character.left, character.top)) {
      character.x += distance;
      character.y += distance;
    } else
    if (!tileWalkableAt(character.right, character.bottom)) {
      character.x -= distance;
      character.y -= distance;
    }
    if (!tileWalkableAt(character.right, character.top)) {
      character.x -= distance;
      character.y += distance;
    } else
    if (!tileWalkableAt(character.left, character.bottom)) {
      character.x += distance;
      character.y -= distance;
    }
  }
}

late AI pathFindAI;
late Node pathFindDestination;
var pathFindSearchID = 0;


int parseRowsAndColumnsToDirection(int rows, int columns) {
  assert(rows != 0 || columns != 0);
  if (rows > 0) {
     if (columns < 0) return Direction.DownLeft;
     if (columns == 0) return Direction.Down;
     return Direction.DownRight;
  }
  if (rows < 0) {
    if (columns < 0) return Direction.UpLeft;
    if (columns == 0) return Direction.Up;
    return Direction.UpRight;
  }
  if (columns < 0) return Direction.Left;
  return Direction.Right;
}

// double getTilePositionX(int row, int column){
//   return (column * halfTileSize) - (row * halfTileSize);
// }
//
// double getTilePositionY(int row, int column){
//   return (row * halfTileSize) + (column * halfTileSize) + halfTileSize;
// }
//
