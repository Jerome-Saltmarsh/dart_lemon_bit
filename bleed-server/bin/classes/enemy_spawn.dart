import '../common/tile_size.dart';
import 'Game.dart';

class EnemySpawn {
  final int z;
  final int row;
  final int column;
  final int framesPerSpawn;
  var framesUntilSpawn = 0;

  EnemySpawn({
    required this.z,
    required this.row,
    required this.column,
    required this.framesPerSpawn,
  });

  void update(Game game){
    if (framesUntilSpawn-- > 0) return;
    framesUntilSpawn = framesPerSpawn;
    game.spawnZombie(
      x: row * tileSize,
      y: column * tileSize,
      z: 24.0,
      team: 0,
      health: 10,
      damage: 1,
    );
  }
}
