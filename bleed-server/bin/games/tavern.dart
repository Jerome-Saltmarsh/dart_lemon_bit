
import 'package:lemon_math/diff_over.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/classes/Vector2.dart';
import '../instances/scenes.dart';
import '../values/world.dart';

class Tavern extends Game {

  Tavern() : super(scenes.tavern, 64);

  @override
  Player doSpawnPlayer() {
    // TODO: implement doSpawnPlayer
    throw UnimplementedError();
  }

  @override
  Vector2 getSpawnPositionFrom(Game from) {
    return Vector2(35, 210);
  }

  @override
  void onPlayerKilled(Player player) {
    // TODO: implement onPlayerKilled
  }

  @override
  void update() {
    for(int i = 0; i < players.length; i++){
      Player player = players[i];
      if (diffOver(player.x, 97, 15)) continue;
      if (diffOver(player.y, 290, 15)) continue;
      changeGame(player, world.town);
      i--;
    }
  }
}