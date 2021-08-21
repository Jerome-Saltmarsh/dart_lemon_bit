import '../constants.dart';
import '../enums.dart';
import '../maths.dart';
import 'Block.dart';
import 'Collectable.dart';
import 'Game.dart';
import 'TileNode.dart';
import 'Vector2.dart';

class Scene {
  final List<List<Tile>> tiles;
  final List<Block> blocks;
  final List<Collectable> collectables;
  final List<Vector2> playerSpawnPoints;
  final List<Vector2> zombieSpawnPoints;

  late final List<List<TileNode>> tileNodes;
  late final int rows;
  late final int columns;

  Scene(this.tiles, this.blocks, this.collectables, this.playerSpawnPoints,
      this.zombieSpawnPoints) {
    rows = tiles.length;
    columns = tiles[0].length;

    tileNodes = [];

    for (int row = 0; row < rows; row++) {
      List<TileNode> nodeRow = [];
      for (int column = 0; column < columns; column++) {
        TileNode node = TileNode(tiles[row][column] == Tile.Concrete);
        node.y = column;
        node.x = row;
        double halfTileSize = 24;
        double px = perspectiveProjectX(node.x * halfTileSize, node.y * halfTileSize);
        double py = perspectiveProjectY(node.x * halfTileSize, node.y * halfTileSize) + halfTileSize;
        node.position = Vector2(px, py);
        nodeRow.add(node);
      }
      tileNodes.add(nodeRow);
    }

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        if (row > 0) {
          tileNodes[row][column].up = tileNodes[row - 1][column];
        } else {
          tileNodes[row][column].up = _boundary;
        }
        if (row < rows - 1) {
          tileNodes[row][column].down = tileNodes[row + 1][column];
        } else {
          tileNodes[row][column].down = _boundary;
        }
        if (column > 0) {
          tileNodes[row][column].left = tileNodes[row][column - 1];
        } else {
          tileNodes[row][column].left = _boundary;
        }
        if (column < columns - 1) {
          tileNodes[row][column].right = tileNodes[row][column + 1];
        } else {
          tileNodes[row][column].right = _boundary;
        }
      }
    }
  }
}

Vector2 _vector2 = Vector2(0, 0);
TileNode _boundary = TileNode(false);

extension SceneFunctions on Scene {
  void sortBlocks() {
    blocks.sort((a, b) => a.leftX < b.leftX ? -1 : 1);
  }

  void addBlock(double x, double y, double width, double length) {
    blocks.add(Block.build(x, y, width, length));
  }

  Vector2 randomPlayerSpawnPoint() {
    return playerSpawnPoints[randomInt(0, playerSpawnPoints.length)];
  }

  List<TileNode> findPath(double x1, double y1, double x2, double y2) {
    TileNode startNode = tileNodeAt(x1, y1);
    TileNode endNode = tileNodeAt(x2, y2);

    if (!startNode.open) return [];
    if (!endNode.open) return [];

    int remaining =
        diffInt(startNode.x, endNode.x) + diffInt(startNode.y, endNode.y);

    List<TileNodeVisit> visits = [TileNodeVisit(null, remaining, startNode)];
    List<TileNode> visited = [startNode];

    void visit(TileNode tileNode) {
      if (!tileNode.open) return;
      if (visited.contains(tileNode)) return;

      int remaining =
          diffInt(tileNode.x, endNode.x) + diffInt(tileNode.y, endNode.y);
      TileNodeVisit tileNodeVisit =
          TileNodeVisit(visits[0], remaining, tileNode);
      visits.add(tileNodeVisit);
    }

    while (visits.isNotEmpty) {
      if (visits[0].tileNode == endNode) {
        TileNodeVisit visit = visits[0];
        List<TileNode> nodes = [];
        while (visit.previous != null) {
          nodes.add(visit.tileNode);
          visit = visit.previous!;
        }
        return nodes.reversed.toList();;
      }

      visit(visits[0].tileNode.up);
      visit(visits[0].tileNode.right);
      visit(visits[0].tileNode.down);
      visit(visits[0].tileNode.left);

      visits.removeAt(0);

      visits.sort((a, b) {
        int scoreA = a.travelled + a.remaining;
        int scoreB = b.travelled + b.remaining;

        if (scoreA < scoreB) return -1;
        if (scoreA > scoreB) return 1;
        if (a.remaining < b.remaining) return -1;
        if (a.remaining > b.remaining) return 1;
        return 0;
      });
    }

    return [];
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

    while (diff(posX, x2) > tileSize || diff(posY, y2) > tileSize) {
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

    double tileX = projectedX / tileSize;
    double tileY = projectedY / tileSize;

    int tileXInt = tileX.toInt();
    int tileYInt = tileY.toInt();

    if (tileX > columns) return Tile.Boundary;
    if (tileY > rows) return Tile.Boundary;

    return tiles[tileYInt][tileXInt];
  }

  TileNode tileNodeAt(double x, double y) {
    double projectedX = projectedToWorldX(x, y);
    if (projectedX < 0) return _boundary;

    double projectedY = projectedToWorldY(x, y);
    if (projectedY < 0) return _boundary;

    double tileX = projectedX / tileSize;
    double tileY = projectedY / tileSize;

    int tileXInt = tileX.toInt();
    int tileYInt = tileY.toInt();

    if (tileX > columns) return _boundary;
    if (tileY > rows) return _boundary;

    return tileNodes[tileYInt][tileXInt];
  }

  bool tileBoundaryAt(double x, double y) {
    Tile tile = tileAt(x, y);
    return tile == Tile.Grass || tile == Tile.Boundary;
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
