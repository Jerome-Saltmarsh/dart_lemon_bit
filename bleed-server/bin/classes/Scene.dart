import 'package:lemon_math/Vector2.dart';

import '../common/Tile.dart';
import '../common/enums/ObjectType.dart';
import '../utilities.dart';
import 'Character.dart';
import 'EnvironmentObject.dart';
import '../enums.dart';
import '../maths.dart';
import 'TileNode.dart';

// constants
const List<Vector2> _emptyPath = [];
const int _tileSize = 48;
const double _tileSizeHalf = _tileSize * 0.5;
final Vector2 _vector2Zero = Vector2(0, 0);
final Vector2 _vector2 = Vector2(0, 0);
final TileNode _boundary = TileNode(false);
// state
int _search = 0;

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
      List<TileNode> nodeRow = [];
      for (int column = 0; column < columns; column++) {
        TileNode node = TileNode(isWalkable(tiles[row][column]));
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
            tileNodes[row][column].leftUp = tileNodes[row - 1][column - 1];
          } else {
            tileNodes[row][column].leftUp = _boundary;
          }
          if (canRight) {
            tileNodes[row][column].upRight = tileNodes[row - 1][column + 1];
          } else {
            tileNodes[row][column].upRight = _boundary;
          }
        } else {
          tileNodes[row][column].up = _boundary;
          tileNodes[row][column].upRight = _boundary;
          tileNodes[row][column].leftUp = _boundary;
        }

        if (canDown) {
          tileNodes[row][column].down = tileNodes[row + 1][column];

          if (canRight) {
            tileNodes[row][column].rightDown = tileNodes[row + 1][column + 1];
          } else {
            tileNodes[row][column].rightDown = _boundary;
          }

          if (canLeft) {
            tileNodes[row][column].downLeft = tileNodes[row + 1][column - 1];
          } else {
            tileNodes[row][column].downLeft = _boundary;
          }
        } else {
          tileNodes[row][column].down = _boundary;
          tileNodes[row][column].rightDown = _boundary;
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

int sortTileNodeVisits(TileNodeVisit a, TileNodeVisit b) {
  if (a.score < b.score) return 1;
  if (a.score > b.score) return -1;
  if (a.remaining < b.remaining) return 1;
  if (a.remaining > b.remaining) return -1;
  if (a.travelled < b.travelled) return 1;
  if (a.travelled > b.travelled) return -1;
  return 0;
}

bool isCloser(TileNodeVisit a, TileNodeVisit b) {
  if (a.score < b.score) return true;
  if (a.score > b.score) return false;
  if (a.remaining < b.remaining) return true;
  if (a.remaining > b.remaining) return false;
  if (a.travelled < b.travelled) return true;
  if (a.travelled > b.travelled) return false;
  return true;
}

extension SceneFunctions on Scene {

  Vector2 getCenterPosition() => getTilePosition(rows ~/ 2, columns ~/ 2);

  List<Vector2> findPath(double x1, double y1, double x2, double y2) {
    TileNode startNode = tileNodeAt(x1, y1);
    if (!startNode.open) return _emptyPath;
    TileNode endNode = tileNodeAt(x2, y2);
    if (!endNode.open) return _emptyPath;
    return findPathNodes(startNode, endNode);
  }

  void visit(TileNode tileNode, TileNodeVisit previous,
      List<TileNodeVisit> visits, TileNode endNode) {
    if (!tileNode.open) return;
    if (tileNode.search == _search) return;

    int remaining =
        diffInt(tileNode.x, endNode.x) + diffInt(tileNode.y, endNode.y);
    TileNodeVisit tileNodeVisit = TileNodeVisit(previous, remaining, tileNode);
    visits.add(tileNodeVisit);
    tileNode.search = _search;
  }

  List<Vector2> findPathNodes(TileNode startNode, TileNode endNode) {
    if (!startNode.open) return _emptyPath;
    if (!endNode.open) return _emptyPath;

    _search++;

    int remaining =
        diffInt(startNode.x, endNode.x) + diffInt(startNode.y, endNode.y);

    List<TileNodeVisit> visits = [TileNodeVisit(null, remaining, startNode)];
    startNode.search = _search;

    while (visits.isNotEmpty) {
      TileNodeVisit closest = visits[0];
      int index = 0;

      for(int i = 1; i < visits.length; i++){
        if (closest.isCloserThan(visits[i])) continue;
        closest = visits[i];
        index = i;
      }

      if (closest.tileNode == endNode) {
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

      if (closest.tileNode.up.open) {
        visit(closest.tileNode.up, closest, visits, endNode);
        if (closest.tileNode.right.open) {
          visit(closest.tileNode.upRight, closest, visits, endNode);
        }
        if (closest.tileNode.left.open) {
          visit(closest.tileNode.upRight, closest, visits, endNode);
        }
      }
      if (closest.tileNode.down.open) {
        visit(closest.tileNode.down, closest, visits, endNode);
        if (closest.tileNode.right.open) {
          visit(closest.tileNode.rightDown, closest, visits, endNode);
        }
        if (closest.tileNode.left.open) {
          visit(closest.tileNode.downLeft, closest, visits, endNode);
        }
      }
      visit(closest.tileNode.right, closest, visits, endNode);
      visit(closest.tileNode.left, closest, visits, endNode);
    }
    return _emptyPath;
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
    return isWater(tileAt(x, y));
  }


  bool tileWalkableAt(double x, double y){
    return isWalkable(tileAt(x, y));
  }

  Tile tileAt(double x, double y) {
    double projectedX = projectedToWorldX(x, y);
    if (projectedX < 0) return Tile.Boundary;

    double projectedY = projectedToWorldY(x, y);
    if (projectedY < 0) return Tile.Boundary;

    double tileX = projectedX / _tileSize;
    int tileXInt = tileX.toInt();
    if (tileX > columns) return Tile.Boundary;

    double tileY = projectedY / _tileSize;
    int tileYInt = tileY.toInt();
    if (tileY > rows) return Tile.Boundary;

    return this.tiles[tileYInt][tileXInt];
  }

  TileNode tileNodeAt(double x, double y) {
    double projectedX = projectedToWorldX(x, y);
    if (projectedX < 0) return _boundary;

    double projectedY = projectedToWorldY(x, y);
    if (projectedY < 0) return _boundary;

    double tileX = projectedX / _tileSize;
    double tileY = projectedY / _tileSize;

    int row = tileY.toInt();
    int column = tileX.toInt();

    if (column >= columns) return _boundary;
    if (row >= rows) return _boundary;

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
}
