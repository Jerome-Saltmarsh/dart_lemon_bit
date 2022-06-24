

import '../classes/library.dart';
import '../common/weapon_type.dart';

class GameFrontline extends Game {

  var time = 12 * 60 * 60;

  GameFrontline(Scene scene) : super(
    scene
  ) {

    npcs.add(InteractableNpc(
      name: "Bell",
      onInteractedWith: (player) {

      },
      x: 300,
      y: 300,
      weapon: 0,
      team: 1,
      health: 10,
    ));
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