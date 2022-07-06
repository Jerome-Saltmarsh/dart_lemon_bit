import '../common/tile_size.dart';
import '../constants/frames_per_second.dart';
import 'game.dart';

class EnemySpawn {
  final int z;
  final int row;
  final int column;
  final int framesPerSpawn;
  final int health;
  var framesUntilSpawn = 0;
  var max;
  var count = 0;

  EnemySpawn({
    required this.z,
    required this.row,
    required this.column,
    required this.health,
    this.framesPerSpawn = framesPerSecond * 5,
    this.max = 5,
  });

  void update(Game game){
    if (count >= max) return;
    if (framesUntilSpawn-- > 0) return;
    framesUntilSpawn = framesPerSpawn;
    count++;
    game.spawnZombie(
      x: row * tileSize + tileSizeHalf,
      y: column * tileSize + tileSizeHalf,
      z: z * tileHeight,
      team: 0,
      health: 10,
      damage: 1,
    ).enemySpawn = this;
  }
}
