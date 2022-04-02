import 'package:lemon_math/Vector2.dart';

import '../common/Tile.dart';
import '../common/enums/Direction.dart';
import '../common/enums/ObjectType.dart';
import '../enums.dart';
import '../utilities.dart';
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
  late final int numberOfRows;
  late final int numberOfColumns;

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
        const halfTileSize = 24.0;
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

    for (var rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
      final tileNodeRow = tileNodes[rowIndex];
      for (var columnIndex = 0; columnIndex < numberOfColumns; columnIndex++) {
        final tileNode = tileNodeRow[columnIndex];
        final canLeft = columnIndex > 0;
        final canRight = columnIndex < numberOfColumns - 1;
        final canUp = rowIndex > 0;
        final canDown = rowIndex < numberOfRows - 1;

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
          tileNode.left = tileNodes[rowIndex][columnIndex - 1];
        } else {
          tileNode.left = _boundary;
        }

        if (canRight) {
          tileNode.right = tileNodes[rowIndex][columnIndex + 1];
        } else {
          tileNode.right = _boundary;
        }
      }
    }

    for (final env in environment){
      const snapToGridTypes = [
        ObjectType.Torch,
        ObjectType.House01,
        ObjectType.House02,
      ];
      if (!snapToGridTypes.contains(env.type)) continue;
       snapToGrid(env);
       final row = getRow(env.x, env.y);
       final column = getColumn(env.x, env.y);
       tileNodes[row][column].open = false;
    }
  }
}

late AI pathFindAI;
late TileNode pathFindDestination;
var pathFindSearchID = 0;

const _maxSearchDepth = 30;

int parseRowsAndColumnsToDirection(int rows, int columns) {
  assert(rows != 0 || columns != 0);
  if (rows > 0) {
     if (columns < 0){
       return 5; // directionDownLeftIndex;
     }
     if (columns == 0){
       return 4; //directionDownIndex;
     }
     return 3; // directionDownRightIndex;
  }
  if (rows < 0) {
    if (columns < 0){
      return 7; // directionUpLeftIndex;
    }
    if (columns == 0){
      return 0; // directionUpIndex;
    }
    return 1; // directionUpRightIndex;
  }
  if (columns < 0){
    return 6; // directionLeftIndex;
  }
  return 2; // directionRightIndex;
}

extension SceneFunctions on Scene {

  void _reserve(TileNode src, TileNode target){
    if (target.reserveId == pathFindSearchID) return;
    target.reserved = src;
    target.reserveId = pathFindSearchID;
  }

  bool visitDirection(int direction, TileNode from){
    // TODO Expensive
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

      if (node.reserveId == pathFindSearchID){
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
    node.reserveSurroundingNodes();
    // _reserve(node, node.up);
    // _reserve(node, node.upRight);
    // _reserve(node, node.right);
    // _reserve(node, node.downRight);
    // _reserve(node, node.down);
    // _reserve(node, node.downLeft);
    // _reserve(node, node.left);
    // _reserve(node, node.upLeft);

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
    if (row >= numberOfRows) return tileBoundary;
    final column = projectedX ~/ _tileSize;
    if (column >= numberOfColumns) return tileBoundary;
    return this.tiles[row][column];
  }

  TileNode tileNodeAt(double x, double y) {
    final projectedX = y - x; // projectedToWorldX(x, y)
    if (projectedX < 0) return _boundary;
    final projectedY = x + y; // projectedToWorldY(x, y)
    if (projectedY < 0) return _boundary;
    final row = projectedY ~/ _tileSize;
    if (row >= numberOfRows) return _boundary;
    final column = projectedX ~/ _tileSize;
    if (column >= numberOfColumns) return _boundary;
    return tileNodes[row][column];
  }

  bool projectileCollisionAt(double x, double y) {
    return !isShootable(tileAt(x, y));
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
