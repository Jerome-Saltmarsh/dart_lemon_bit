import 'package:lemon_math/library.dart';

import '../common/library.dart';
import '../enums.dart';
import '../utilities.dart';
import 'Character.dart';
import 'DynamicObject.dart';
import 'EnvironmentObject.dart';
import 'TileNode.dart';

class Scene {
  final List<Character> characters;
  final List<List<int>> tiles;
  final List<Vector2> crates;
  final List<StaticObject> staticObjects;
  final List<DynamicObject> dynamicObjects;
  final String name;

  late final List<List<TileNode>> tileNodes;
  late final int numberOfRows;
  late final int numberOfColumns;

  int? startHour;
  int? secondsPerFrames;
  List<Vector2> playerSpawnPoints = [];

  static final _boundary = TileNode(false);

  int get rows => tiles.length;
  int get columns => rows > 0 ? tiles[0].length : 0;

  Scene({
    required this.tiles,
    required this.crates,
    required this.staticObjects,
    required this.dynamicObjects,
    required this.characters,
    required this.name,
  }) {
    numberOfRows = tiles.length;
    numberOfColumns = numberOfRows > 0 ? tiles[0].length : 0;
    tileNodes = [];

    for (var rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
      final List<TileNode> nodeRow = [];
      final tileRow = tiles[rowIndex];
      for (var columnIndex = 0; columnIndex < numberOfColumns; columnIndex++) {
        final node = TileNode(isWalkable(tileRow[columnIndex]));
        node.row = rowIndex;
        node.column = columnIndex;
        node.x = getTilePositionX(node.row, node.column);
        node.y = getTilePositionY(node.row, node.column);
        nodeRow.add(node);
      }
      tileNodes.add(nodeRow);
    }

    for (var rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
      final tileNodeRow = tileNodes[rowIndex];
      final canUp = rowIndex > 0;
      final canDown = rowIndex < numberOfRows - 1;
      for (var columnIndex = 0; columnIndex < numberOfColumns; columnIndex++) {
        final tileNode = tileNodeRow[columnIndex];
        final canLeft = columnIndex > 0;
        final canRight = columnIndex < numberOfColumns - 1;

        if (canUp) {
          tileNode.up = tileNodes[rowIndex - 1][columnIndex];
          if (canLeft) {
            tileNode.upLeft = tileNodes[rowIndex - 1][columnIndex - 1];
          } else {
            tileNode.upLeft = _boundary;
          }
          if (canRight) {
            tileNode.upRight = tileNodes[rowIndex - 1][columnIndex + 1];
          } else {
            tileNode.upRight = _boundary;
          }
        } else {
          tileNode.up = _boundary;
          tileNode.upRight = _boundary;
          tileNode.upLeft = _boundary;
        }

        if (canDown) {
          tileNode.down = tileNodes[rowIndex + 1][columnIndex];

          if (canRight) {
            tileNode.downRight = tileNodes[rowIndex + 1][columnIndex + 1];
          } else {
            tileNode.downRight = _boundary;
          }

          if (canLeft) {
            tileNode.downLeft = tileNodes[rowIndex + 1][columnIndex - 1];
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

    for (final env in staticObjects) {
       snapToGrid(env);
       tileNodeAt(env).obstructed = true;
    }

    for (var i = 0; i < staticObjects.length; i++) {
       final env = staticObjects[i];
       if (env.type == ObjectType.Rock) {
          staticObjects.removeAt(i);
          i--;
          dynamicObjects.add(
              DynamicObject(
                  type: DynamicObjectType.Rock,
                  x: env.x,
                  y: env.y,
                  health: 50
              )
          );
       }
       if (env.type == ObjectType.Tree01) {
         staticObjects.removeAt(i);
         i--;
         dynamicObjects.add(
             DynamicObject(
                 type: DynamicObjectType.Tree,
                 x: env.x,
                 y: env.y,
                 health: 10
             )
         );
       }
    }
  }

  int tileAt(double x, double y) {
    final projectedX = y - x;
    if (projectedX < 0) return tileBoundary;
    final projectedY = x + y;
    if (projectedY < 0) return tileBoundary;
    const tileSize = 48;
    final row = projectedY ~/ tileSize;
    if (row >= numberOfRows) return tileBoundary;
    final column = projectedX ~/ tileSize;
    if (column >= numberOfColumns) return tileBoundary;
    return this.tiles[row][column];
  }


  bool visitDirection(int direction, TileNode from) {
    if (direction == Direction.UpLeft && !from.up.open && !from.left.open) return false;
    if (direction == Direction.DownLeft && !from.down.open && !from.left.open) return false;
    if (direction == Direction.DownRight && !from.down.open && !from.right.open) return false;
    if (direction == Direction.UpRight && !from.up.open && !from.right.open) return false;
    return visitNode(from.getNodeByDirection(direction), from);
  }

  bool visitNodeFirst(TileNode node){
    node.depth = 0;
    node.previous = null;
    node.searchId = pathFindSearchID;

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

  bool visitNode(TileNode node, TileNode previous) {
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

  bool waterAt(double x, double y) {
    return tileAt(x, y) == Tile.Water;
  }

  bool tileWalkableAt(double x, double y){
    return tileNodeAtXY(x, y).open;
  }

  TileNode tileNodeAt(Position position) {
    return tileNodeAtXY(position.x, position.y);
  }

  TileNode tileNodeAtXY(double x, double y) {
    final projectedX = y - x; // projectedToWorldX(x, y)
    if (projectedX < 0) return _boundary;
    final projectedY = x + y; // projectedToWorldY(x, y)
    if (projectedY < 0) return _boundary;
    const tileSize = 48;
    final row = projectedY ~/ tileSize;
    if (row >= numberOfRows) return _boundary;
    final column = projectedX ~/ tileSize;
    if (column >= numberOfColumns) return _boundary;
    return tileNodes[row][column];
  }

  bool projectileCollisionAt(double x, double y) {
    return !isShootable(tileAt(x, y));
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
late TileNode pathFindDestination;
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

double getTilePositionX(int row, int column){
  return (column * halfTileSize) - (row * halfTileSize);
}

double getTilePositionY(int row, int column){
  return (row * halfTileSize) + (column * halfTileSize) + halfTileSize;
}

