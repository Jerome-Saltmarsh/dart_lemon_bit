import '../common/Tile.dart';
import '../common/classes/Vector2.dart';
import '../enums.dart';
import '../maths.dart';
import 'Block.dart';
import 'TileNode.dart';

// constants
const List<Vector2> _emptyPath = [];
const int _tileSize = 48;
final Vector2 _vector2Zero = Vector2(0, 0);
final Vector2 _vector2 = Vector2(0, 0);
final TileNode _boundary = TileNode(false);
// state
int _search = 0;

class Scene {
  final List<List<Tile>> tiles;
  final List<Block> blocks;
  final List<Vector2> crates;
  late Vector2 fortressPosition;

  late final List<List<TileNode>> tileNodes;
  late final int rows;
  late final int columns;

  Scene({required this.tiles, required this.blocks, required this.crates}) {
    rows = tiles.length;
    columns = tiles[0].length;
    tileNodes = [];

    for (int row = 0; row < rows; row++) {
      List<TileNode> nodeRow = [];
      for (int column = 0; column < columns; column++) {
        TileNode node = TileNode(isOpen(tiles[row][column]));
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

        // TODO Does not belong
        if (tiles[row][column] == Tile.Fortress) {
          fortressPosition = node.position;
        }
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
  int scoreA = a.travelled + a.remaining;
  int scoreB = b.travelled + b.remaining;
  if (scoreA < scoreB) return 1;
  if (scoreA > scoreB) return -1;
  if (a.remaining < b.remaining) return 1;
  if (a.remaining > b.remaining) return -1;
  return 0;
}

extension SceneFunctions on Scene {
  void sortBlocks() {
    blocks.sort((a, b) => a.leftX < b.leftX ? -1 : 1);
  }

  void addBlock(double x, double y, double width, double length) {
    blocks.add(Block.build(x, y, width, length));
  }

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
      if (visits.last.tileNode == endNode) {
        TileNodeVisit visit = visits.last;
        List<Vector2> nodes =
            List.filled(visit.travelled, _vector2Zero, growable: true);
        int index = visit.travelled - 1;
        while (visit.previous != null) {
          nodes[index] = visit.tileNode.position;
          index--;
          visit = visit.previous!;
        }
        visits.clear();
        return nodes;
      }

      TileNodeVisit last = visits.removeLast();

      if (last.tileNode.up.open) {
        visit(last.tileNode.up, last, visits, endNode);
        if (last.tileNode.right.open) {
          visit(last.tileNode.upRight, last, visits, endNode);
        }
        if (last.tileNode.left.open) {
          visit(last.tileNode.upRight, last, visits, endNode);
        }
      }
      if (last.tileNode.down.open) {
        visit(last.tileNode.down, last, visits, endNode);
        if (last.tileNode.right.open) {
          visit(last.tileNode.rightDown, last, visits, endNode);
        }
        if (last.tileNode.left.open) {
          visit(last.tileNode.downLeft, last, visits, endNode);
        }
      }
      visit(last.tileNode.right, last, visits, endNode);
      visit(last.tileNode.left, last, visits, endNode);
      visits.sort(sortTileNodeVisits);
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

  bool pathClear(double x1, double y1, double x2, double y2) {
    double angle = radiansBetween(x1, y1, x2, y2);
    double posX = x1;
    double posY = y1;
    double vx = velX(angle, 24);
    double vy = velY(angle, 24);

    while (diff(posX, x2) > _tileSize || diff(posY, y2) > _tileSize) {
      if (tileBoundaryAt(posX, posY)) return false;
      posX += vx;
      posY += vy;
    }
    return true;
  }

  Tile tileAt(double x, double y) {
    double projectedX = projectedToWorldX(x, y);
    if (projectedX < 0) return Tile.Boundary;

    double projectedY = projectedToWorldY(x, y);
    if (projectedY < 0) return Tile.Boundary;

    double tileX = projectedX / _tileSize;
    double tileY = projectedY / _tileSize;

    int tileXInt = tileX.toInt();
    int tileYInt = tileY.toInt();

    if (tileX > columns) return Tile.Boundary;
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

  bool tileBoundaryAt(double x, double y) {
    return !isOpen(tileAt(x, y));
  }

  double perspectiveProjectX(double x, double y) {
    return -y + x;
  }

  double perspectiveProjectY(double x, double y) {
    return x + y;
  }

  double projectedToWorldX(double x, double y) {
    return y - x;
  }

  double projectedToWorldY(double x, double y) {
    return x + y;
  }
}
