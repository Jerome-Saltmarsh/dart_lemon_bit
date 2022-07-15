import 'package:lemon_math/library.dart';

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
  var wanderRadius = 300.0;

  double get x => row * tileSize;
  double get y => column * tileSize;

  EnemySpawn({
    required this.z,
    required this.row,
    required this.column,
    required this.health,
    this.framesPerSpawn = framesPerSecond * 5,
    this.max = 5,
    this.wanderRadius = 300,
  });

  void update(Game game){
    if (count >= max) return;
    if (framesUntilSpawn-- > 0) return;
    framesUntilSpawn = framesPerSpawn;
    count++;

    game.spawnZombie(
      x: row * tileSize + tileSizeHalf + giveOrTake(wanderRadius),
      y: column * tileSize + tileSizeHalf + giveOrTake(wanderRadius),
      z: z * tileHeight,
      team: 0,
      health: 10,
      damage: 1,
      wanderRadius: wanderRadius,
    ).enemySpawn = this;
  }
}
