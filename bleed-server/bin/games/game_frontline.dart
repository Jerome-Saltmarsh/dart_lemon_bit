

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Scene.dart';
import '../common/grid_node_type.dart';
import '../common/weapon_type.dart';

class GameFrontline extends Game {

  var time = 12 * 60 * 60;

  GameFrontline(Scene scene) : super(
    scene
  );

  @override
  int getTime() {
    return time;
  }

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        weapon: WeaponType.Shotgun,
    );

    for (var z = 0; z < scene.gridHeight; z++) {
       for (var r = 0; r < scene.gridRows; r++){
          for (var c = 0; c < scene.gridColumns; c++){
              if (scene.grid[z][r][c].type != GridNodeType.Player_Spawn) continue;
              player.indexZ = z;
              player.indexRow = r;
              player.indexColumn = c;
              break;
          }
       }
    }

    return player;
  }

  @override
  bool get full => false;
}