import 'package:lemon_math/Vector2.dart';

import '../common/Tile.dart';
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
TileNode? pathFindPrevious = null;
var pathFindSearch = 0;

extension SceneFunctions on Scene {

  bool visitNode({
    required TileNode node,
  }){
    if (!node.open) return false;
    if (node.search == pathFindSearch) return false;
    node.search = pathFindSearch;
    node.previous = pathFindPrevious;
    pathFindPrevious = node;

    if (node == pathFindDestination) {
      TileNode? current = node;
      var index = 0;
      while (current != null) {
        pathFindAI.pathX[index] = current.position.x;
        pathFindAI.pathY[index] = current.position.y;
        current = current.previous;
        if (current != null){
          index++;
        }
      }
      pathFindAI.pathIndex = index;
      return true;
    }

    final distanceRows = pathFindDestination.row - node.row;
    final distanceColumns = pathFindDestination.column - node.column;

    if (distanceRows < 0) {
      if (distanceColumns < 0) {
         if (node.up.open || node.left.open){
           if (visitNode(node: node.upLeft)) {
             return true;
           }
           if (visitNode(node: node.left)) {
             return true;
           }
           if (visitNode(node: node.up)) {
             return true;
           }
         }
      } else if (distanceColumns > 0) {
        if (node.up.open || node.right.open) {
          if (visitNode(node: node.upRight)) {
            return true;
          }
          if (visitNode(node: node.right)) {
            return true;
          }
          if (visitNode(node: node.up)) {
            return true;
          }
        }
      } else if (visitNode(node: node.up)) {
        return true;
      }
    } else if (distanceRows > 0) { // look down

      if (distanceColumns < 0) {
        if (node.down.open || node.left.open){
          if (visitNode(node: node.downLeft)) {
            return true;
          }
          if (visitNode(node: node.left)) {
            return true;
          }
          if (visitNode(node: node.down)) {
            return true;
          }
        }
      } else if (distanceColumns > 0) {
        if (node.down.open || node.right.open) {
          if (visitNode(node: node.downRight)) {
            return true;
          }
          if (visitNode(node: node.right)) {
            return true;
          }
          if (visitNode(node: node.down)) {
            return true;
          }
        }
      } else if (visitNode(node: node.down)) { // down
        return true;
      }
    } else {
      if (distanceColumns < 0){
         if (visitNode(node: node.left)){
           return true;
         }
      } else if (visitNode(node: node.right)) {
          return true;
      }
    }

    // if (visitNode(node: node.up)){
    //   return true;
    // }
    // if (visitNode(node: node.right)){
    //   return true;
    // }
    // if (visitNode(node: node.down)){
    //   return true;
    // }
    // if (visitNode(node: node.left)){
    //   return true;
    // }
    return false;
  }

  // Vector2 getLeft(double x1, double y1, double x2, double y2) {
  //   double middleX = (x2 - x1) * 0.5;
  //   double middleY = (y2 - y1) * 0.5;
  //   double perpendicularX = middleY;
  //   double perpendicularY = -middleX;
  //   _vector2.x = x1 + middleX + perpendicularX;
  //   _vector2.y = y1 + middleY + perpendicularY;
  //   return _vector2;
  // }
  //
  // Vector2 getRight(double x1, double y1, double x2, double y2) {
  //   double middleX = (x2 - x1) * 0.5;
  //   double middleY = (y2 - y1) * 0.5;
  //   double perpendicularX = -middleY;
  //   double perpendicularY = middleX;
  //   _vector2.x = x1 + middleX + perpendicularX;
  //   _vector2.y = y1 + middleY + perpendicularY;
  //   return _vector2;
  // }

  bool waterAt(double x, double y) {
    return tileAt(x, y).isWater;
  }

  bool tileWalkableAt(double x, double y){
    return isWalkable(tileAt(x, y));
  }

  Tile tileAt(double x, double y) {
    final projectedX = y - x;
    if (projectedX < 0) return Tile.Boundary;
    final projectedY = x + y;
    if (projectedY < 0) return Tile.Boundary;
    final row = projectedY ~/ _tileSize;
    if (row >= rows) return Tile.Boundary;
    final column = projectedX ~/ _tileSize;
    if (column >= columns) return Tile.Boundary;
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

  bool bulletCollisionAt(double x, double y) {
    return isBulletCollideable(tileAt(x, y));
  }

  double projectedToWorldX(double x, double y) {
    return y - x;
  }

  double projectedToWorldY(double x, double y) {
    return x + y;
  }

  void resolveCharacterTileCollision(Character character) {
    if (!tileWalkableAt(character.left, character.top)) {
      character.x += 3;
      character.y += 3;
    } else
    if (!tileWalkableAt(character.right, character.bottom)) {
      character.x -= 3;
      character.y -= 3;
    }
    if (!tileWalkableAt(character.right, character.top)) {
      character.x -= 3;
      character.y += 3;
    } else
    if (!tileWalkableAt(character.left, character.bottom)) {
      character.x += 3;
      character.y -= 3;
    }
  }
}
