import '../common/tile_size.dart';
import '../constants/frames_per_second.dart';
import 'Game.dart';

class EnemySpawn {
  final int z;
  final int row;
  final int column;
  final int framesPerSpawn;
  var framesUntilSpawn = 0;
  var count = 0;

  EnemySpawn({
    required this.z,
    required this.row,
    required this.column,
    this.framesPerSpawn = framesPerSecond * 5,
  });

  void update(Game game){
    if (count >= 3) return;
    if (framesUntilSpawn-- > 0) return;
    framesUntilSpawn = framesPerSpawn;
    count++;
    game.spawnZombie(
      x: row * tileSize,
      y: column * tileSize,
      z: 24.0,
      team: 0,
      health: 10,
      damage: 1,
    ).enemySpawn = this;
  }
}
