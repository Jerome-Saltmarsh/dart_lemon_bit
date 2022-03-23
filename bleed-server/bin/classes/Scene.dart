import 'package:lemon_math/Vector2.dart';

import '../common/Tile.dart';
import '../common/enums/Direction.dart';
import '../common/enums/ObjectType.dart';
import '../enums.dart';
import 'Character.dart';
import 'EnvironmentObject.dart';
import 'TileNode.dart';

// constants
const _tileSize = 48;
const _tileSizeHalf = _tileSize * 0.5;
final _boundary = TileNode(false);

double mapTilePositionX(int row, int column) {
  return perspectiveProjectX(row * _tileSizeHalf, column * _tileSizeHalf);
}

double mapTilePositionY(int row, int column) {
  return perspectiveProjectY(row * _tileSizeHalf, column * _tileSizeHalf);
}

double perspectiveProjectX(double x, double y) {
  return -y + x;
}

double perspectiveProjectY(double x, double y) {
  return x + y;
}

class Scene {
  final List<Character> characters;
  final List<List<Tile>> tiles;
  final List<Vector2> crates;
  final List<EnvironmentObject> environment;
  final String name;

  late final List<List<TileNode>> tileNodes;
  late final int rows;
  late final int columns;

  int? startHour;
  int? secondsPerFrames;
  List<Vector2> playerSpawnPoints = [];

  Scene({
    required this.tiles,
    required this.crates,
    required this.environment,
    required this.characters,
    required this.name,
  }) {
    rows = tiles.length;
    columns = tiles[0].length;
    tileNodes = [];

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {

        Tile tile = tiles[row][column];

        if (tile == Tile.Block) {
          environment.add(EnvironmentObject(
              x: mapTilePositionX(row, column),
              y: mapTilePositionY(row, column) + _tileSizeHalf,
              type: ObjectType.Palisade));
        } else

        if (tile == Tile.Block_Horizontal) {
          environment.add(EnvironmentObject(
              x: mapTilePositionX(row, column),
              y: mapTilePositionY(row, column) + _tileSizeHalf,
              type: ObjectType.Palisade_H));
        } else

        if (tile == Tile.Block_Vertical) {
          environment.add(EnvironmentObject(
              x: mapTilePositionX(row, column),
              y: mapTilePositionY(row, column)+ _tileSizeHalf,
              type: ObjectType.Palisade_V));
        }

        else

        if (tile == Tile.Rock_Wall) {
          environment.add(EnvironmentObject(
              x: mapTilePositionX(row, column),
              y: mapTilePositionY(row, column)+ _tileSizeHalf,
              type: ObjectType.Rock_Wall));
        }
      }
    }

    for (var row = 0; row < rows; row++) {
      final List<TileNode> nodeRow = [];
      for (var column = 0; column < columns; column++) {
        final node = TileNode(isWalkable(tiles[row][column]));
        node.row = row;
        node.column = column;
        final halfTileSize = 24.0;
        final px =
            perspectiveProjectX(node.row * halfTileSize, node.column * halfTileSize);
        final py =
            perspectiveProjectY(node.row * halfTileSize, node.column * halfTileSize) +
                halfTileSize;
        node.position = Vector2(px, py);
        nodeRow.add(node);
      }
      tileNodes.add(nodeRow);
    }

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        bool canLeft = column > 0;
        bool canRight = column < columns - 1;
        bool canUp = row > 0;
        bool canDown = row < rows - 1;

        if (canUp) {
          tileNodes[row][column].up = tileNodes[row - 1][column];
          if (canLeft) {
            tileNodes[row][column].upLeft = tileNodes[row - 1][column - 1];
          } else {
            tileNodes[row][column].upLeft = _boundary;
          }
          if (canRight) {
            tileNodes[row][column].upRight = tileNodes[row - 1][column + 1];
          } else {
            tileNodes[row][column].upRight = _boundary;
          }
        } else {
          tileNodes[row][column].up = _boundary;
          tileNodes[row][column].upRight = _boundary;
          tileNodes[row][column].upLeft = _boundary;
        }

        if (canDown) {
          tileNodes[row][column].down = tileNodes[row + 1][column];

          if (canRight) {
            tileNodes[row][column].downRight = tileNodes[row + 1][column + 1];
          } else {
            tileNodes[row][column].downRight = _boundary;
          }

          if (canLeft) {
            tileNodes[row][column].downLeft = tileNodes[row + 1][column - 1];
          } else {
            tileNodes[row][column].downLeft = _boundary;
          }
        } else {
          tileNodes[row][column].down = _boundary;
          tileNodes[row][column].downRight = _boundary;
          tileNodes[row][column].downLeft = _boundary;
        }

        if (canLeft) {
          tileNodes[row][column].left = tileNodes[row][column - 1];
        } else {
          tileNodes[row][column].left = _boundary;
        }

        if (canRight) {
          tileNodes[row][column].right = tileNodes[row][column + 1];
        } else {
          tileNodes[row][column].right = _boundary;
        }
      }
    }
  }
}

late AI pathFindAI;
late TileNode pathFindDestination;
var pathFindSearchID = 0;

const _maxSearchDepth = 30;

int parseRowsAndColumnsToDirection(int rows, int columns){
  assert(rows != 0 || columns != 0);
  if (rows > 0) {
     if (columns < 0){
       return directionDownLeftIndex;
     }
     if (columns == 0){
       return directionDownIndex;
     }
     return directionDownRightIndex;
  }
  if (rows < 0) {
    if (columns < 0){
      return directionUpLeftIndex;
    }
    if (columns == 0){
      return directionUpIndex;
    }
    return directionUpRightIndex;
  }
  if (columns < 0){
    return directionLeftIndex;
  }
  return directionRightIndex;
}

extension SceneFunctions on Scene {

  void _reserve(TileNode src, TileNode target){
    if (target.reservedSearchId == pathFindSearchID) return;
    target.reserved = src;
    target.reservedSearchId = pathFindSearchID;
  }

  bool visitDirection(int direction, TileNode from){
    switch(direction){
      case directionUpIndex:
        return visitNode(from.up, previous: from);
      case directionUpRightIndex:
        return visitNode(from.upRight, previous: from);
      case directionRightIndex:
        return visitNode(from.right, previous: from);
      case directionDownRightIndex:
        return visitNode(from.downRight, previous: from);
      case directionDownIndex:
        return visitNode(from.down, previous: from);
      case directionDownLeftIndex:
        return visitNode(from.downLeft, previous: from);
      case directionLeftIndex:
        return visitNode(from.left, previous: from);
      case directionUpLeftIndex:
        return visitNode(from.upLeft, previous: from);
      default:
        throw Exception("Invalid Direction index $direction");
    }
  }

  bool visitNode(TileNode node, {TileNode? previous}){
    if (!node.open) return false;
    if (previous != null) {
      if (node.searchId == pathFindSearchID) {
        return false;
      }

      if (node.reservedSearchId == pathFindSearchID){
        if (node.reserved != previous){
          return visitNode(node, previous: node.reserved);
        }
      }

      node.depth = previous.depth + 1;
    } else {
      node.depth = 0;
    }

    node.previous = previous;
    node.searchId = pathFindSearchID;

    if (node == pathFindDestination) {
      TileNode? current = node.previous;
      final pathX = pathFindAI.pathX;
      final pathY = pathFindAI.pathY;
      var index = 0;
      while (current != null) {
        final position = current.position;
        pathX[index] = position.x;
        pathY[index] = position.y;
        current = current.previous;
        if (current != null){
          index++;
          if (index >= maxAIPathLength) return false;
        }
      }
      pathFindAI.pathIndex = index;
      return true;
    }

    if (node.depth > _maxSearchDepth) {
      return false;
    }

    final distanceRows = pathFindDestination.row - node.row;
    final distanceColumns = pathFindDestination.column - node.column;
    final direction = parseRowsAndColumnsToDirection(distanceRows, distanceColumns);
    _reserve(node, node.up);
    _reserve(node, node.upRight);
    _reserve(node, node.right);
    _reserve(node, node.downRight);
    _reserve(node, node.down);
    _reserve(node, node.downLeft);
    _reserve(node, node.left);
    _reserve(node, node.upLeft);

    if (visitDirection(direction, node)){
      return true;
    }

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
    return tileAt(x, y).isWater;
  }

  bool tileWalkableAt(double x, double y){
    return tileNodeAt(x, y).open;
  }

  Tile tileAt(double x, double y) {
    final projectedX = y - x;
    if (projectedX < 0) return tileBoundary;
    final projectedY = x + y;
    if (projectedY < 0) return tileBoundary;
    final row = projectedY ~/ _tileSize;
    if (row >= rows) return tileBoundary;
    final column = projectedX ~/ _tileSize;
    if (column >= columns) return tileBoundary;
    return this.tiles[row][column];
  }

  TileNode tileNodeAt(double x, double y) {
    final projectedX = y - x; // projectedToWorldX(x, y)
    if (projectedX < 0) return _boundary;
    final projectedY = x + y; // projectedToWorldY(x, y)
    if (projectedY < 0) return _boundary;
    final row = projectedY ~/ _tileSize;
    if (row >= rows) return _boundary;
    final column = projectedX ~/ _tileSize;
    if (column >= columns) return _boundary;
    return tileNodes[row][column];
  }

  bool projectileCollisionAt(double x, double y) {
    return isProjectileCollideable(tileAt(x, y));
  }

  double projectedToWorldX(double x, double y) {
    return y - x;
  }

  double projectedToWorldY(double x, double y) {
    return x + y;
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
