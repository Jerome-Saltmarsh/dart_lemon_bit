

import '../classes/game.dart';
import '../classes/player.dart';
import '../classes/scene.dart';
import '../common/weapon_type.dart';

class GameFrontline extends Game {

  var time = 12 * 60 * 60;

  GameFrontline(Scene scene) : super(
    scene
  ) {


  }

  @override
  int getTime() => time;

  @override
  Player spawnPlayer() {
    final player = Player(
        game: this,
        weapon: WeaponType.Shotgun,
    );
    movePlayerToSpawn(player);
    return player;
  }

  @override
  bool get full => false;

  @override
  void onPlayerDeath(Player player) {
    revive(player);
  }
}