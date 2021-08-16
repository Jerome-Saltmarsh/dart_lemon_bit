
import '../classes.dart';
import '../enums.dart';
import '../maths.dart';
import 'Block.dart';
import 'Collectable.dart';
import 'Vector2.dart';

class Scene {
  final List<List<Tile>> tiles;
  final List<Block> blocks;
  final List<Collectable> collectables;
  final List<Vector2> playerSpawnPoints;
  final List<Vector2> zombieSpawnPoints;

  Scene(this.tiles, this.blocks, this.collectables, this.playerSpawnPoints, this.zombieSpawnPoints);
}

extension SceneFunctions on Scene {
  void sortBlocks(){
    blocks.sort((a, b) => a.leftX < b.leftX ? -1 : 1);
  }

  void addBlock(double x, double y, double width, double length){
    blocks.add(Block.build(x, y, width, length));
  }

  Vector2 randomPlayerSpawnPoint(){
    return playerSpawnPoints[randomInt(0, playerSpawnPoints.length)];
  }
}