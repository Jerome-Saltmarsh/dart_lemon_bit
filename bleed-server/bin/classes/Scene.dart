import 'package:lemon_math/Vector2.dart';

import '../common/Tile.dart';
import '../common/enums/ObjectType.dart';
import '../enums.dart';
import '../maths.dart';
import 'Character.dart';
import 'EnvironmentObject.dart';
import 'TileNode.dart';

// constants
const List<Vector2> _emptyPath = [];
const _tileSize = 48;
const _tileSizeHalf = _tileSize * 0.5;
final _vector2Zero = Vector2(0, 0);
final _vector2 = Vector2(0, 0);
final _boundary = TileNode(false);
// variables
var _search = 0;

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

    for (int row = 0; row < rows; row++) {
      final List<TileNode> nodeRow = [];
      for (int column = 0; column < columns; column++) {
        final node = TileNode(isWalkable(tiles[row][column]));
        node.y = column;
        node.x = row;
        double halfTileSize = 24;
        double px =
            perspectiveProjectX(node.x * halfTileSize, node.y * halfTileSize);
        double py =
            perspectiveProjectY(node.x * halfTileSize, node.y * halfTileSize) +
                halfTileSize;
        node.position = Vector2(px, py);
        nodeRow.add(node);
      }
      tileNodes.add(nodeRow);
    }

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
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

const _findPathMaxDistance = 10;

late AI pathFindAI;
late TileNode pathFindDestination;

extension SceneFunctions on Scene {

  List<Vector2> findPath(double x1, double y1, double x2, double y2) {
    final startNode = tileNodeAt(x1, y1);
    if (!startNode.open) return _emptyPath;
    final endNode = tileNodeAt(x2, y2);
    if (!endNode.open) return _emptyPath;
    return findPathNodes(startNode, endNode);
  }

  void visit(TileNode tileNode, TileNodeVisit previous,
      List<TileNodeVisit> visits, TileNode endNode) {
    if (!tileNode.open) return;
    if (tileNode.search == _search) return;

    final remaining = diffInt(tileNode.x, endNode.x) + diffInt(tileNode.y, endNode.y);
    final tileNodeVisit = TileNodeVisit(previous, remaining, tileNode);
    visits.add(tileNodeVisit);
    tileNode.search = _search;
  }

  List<Vector2> findPathNodes(TileNode startNode, TileNode endNode) {
    if (!startNode.open) return _emptyPath;
    if (!endNode.open) return _emptyPath;

    _search++;

    final remaining =
        diffInt(startNode.x, endNode.x) + diffInt(startNode.y, endNode.y);

    List<TileNodeVisit> visits = [TileNodeVisit(null, remaining, startNode)];
    startNode.search = _search;

    while (visits.isNotEmpty) {
      var closest = visits[0];
      var index = 0;

      for(int i = 1; i < visits.length; i++){
        if (closest.isCloserThan(visits[i])) continue;
        closest = visits[i];
        index = i;
      }

      if (closest.travelled > _findPathMaxDistance || closest.tileNode == endNode) {
        List<Vector2> nodes =
        List.filled(closest.travelled, _vector2Zero, growable: true);
        int index = closest.travelled - 1;
        while (closest.previous != null) {
          nodes[index] = closest.tileNode.position;
          index--;
          closest = closest.previous!;
        }
        visits.clear();
        return nodes;
      }

      visits.removeAt(index);
      
      final closestNode = closest.tileNode;

      if (closestNode.up.open) {
        visit(closestNode.up, closest, visits, endNode);
        if (closestNode.right.open) {
          visit(closestNode.upRight, closest, visits, endNode);
        }
        if (closestNode.left.open) {
          visit(closestNode.upLeft, closest, visits, endNode);
        }
      }
      if (closestNode.down.open) {
        visit(closestNode.down, closest, visits, endNode);
        if (closestNode.right.open) {
          visit(closestNode.downRight, closest, visits, endNode);
        }
        if (closestNode.left.open) {
          visit(closestNode.downLeft, closest, visits, endNode);
        }
      }
      visit(closestNode.right, closest, visits, endNode);
      visit(closestNode.left, closest, visits, endNode);
    }
    return _emptyPath;
  }

  bool visitNode({
    required TileNode node,
    TileNode? previous,
  }){

    if (!node.open) return false;
    if (node.search == _search) return false;
    node.search = _search;

    if (node == pathFindDestination){
      node.previous = previous;
      TileNode n = node;
      var index = 0;
      while (n.previous != null) {
        pathFindAI.pathX[index] = n.position.x;
        pathFindAI.pathY[index] = n.position.y;
        index++;
        n = n.previous!;
      }
      pathFindAI.pathIndex = index;
      return true;
    }

    node.previous = previous;
    final distanceX = pathFindDestination.x - node.x;
    final distanceY = pathFindDestination.y - node.y;

    if (distanceX < 0) {
      if (distanceY < 0) {
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
      } else if (distanceY > 0) { // down left
        if (node.down.open || node.left.open) {
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
      } else if (visitNode(node: node.left)) {
        return true;
      }
    } else if (distanceX > 0) { // otherwise look right

      if (distanceY < 0) {
        if (node.up.open || node.right.open){
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
      } else if (distanceY > 0) { // down left
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
      } else if (visitNode(node: node.right)) {
        return true;
      }
    } else {
      // distanceX is zero
      if (distanceY < 0){
         if (visitNode(node: node.up)){
           return true;
         }
      }
       if (visitNode(node: node.down)){
          return true;
       }
    }

    if (visitNode(node: node.up)){
      return true;
    }
    if (visitNode(node: node.right)){
      return true;
    }
    if (visitNode(node: node.down)){
      return true;
    }
    if (visitNode(node: node.left)){
      return true;
    }
    return false;
  }

  Vector2 getLeft(double x1, double y1, double x2, double y2) {
    double middleX = (x2 - x1) * 0.5;
    double middleY = (y2 - y1) * 0.5;
    double perpendicularX = middleY;
    double perpendicularY = -middleX;
    _vector2.x = x1 + middleX + perpendicularX;
    _vector2.y = y1 + middleY + perpendicularY;
    return _vector2;
  }

  Vector2 getRight(double x1, double y1, double x2, double y2) {
    double middleX = (x2 - x1) * 0.5;
    double middleY = (y2 - y1) * 0.5;
    double perpendicularX = -middleY;
    double perpendicularY = middleX;
    _vector2.x = x1 + middleX + perpendicularX;
    _vector2.y = y1 + middleY + perpendicularY;
    return _vector2;
  }

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
