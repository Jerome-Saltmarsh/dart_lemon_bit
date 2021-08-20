import '../enums.dart';
import '../maths.dart';
import 'Block.dart';
import 'Collectable.dart';
import 'Game.dart';
import 'Vector2.dart';

class Scene {
  final List<List<Tile>> tiles;
  final List<Block> blocks;
  final List<Collectable> collectables;
  final List<Vector2> playerSpawnPoints;
  final List<Vector2> zombieSpawnPoints;

  late int rows;
  late int columns;

  Scene(this.tiles, this.blocks, this.collectables, this.playerSpawnPoints,
      this.zombieSpawnPoints) {
    rows = tiles.length;
    columns = tiles[0].length;
  }
}

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

  List<Vector2> findPath(Vector2 start, Vector2 end) {
    return [];
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

  bool tileBoundaryAt(double x, double y) {
    Tile tile = tileAt(x, y);
    return tile == Tile.Grass || tile == Tile.Boundary;
  }

  double projectedToWorldX(double x, double y) {
    return y - x;
  }

  double projectedToWorldY(double x, double y) {
    return x + y;
  }
}
