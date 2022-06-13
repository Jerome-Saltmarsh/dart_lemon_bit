

import 'package:lemon_math/library.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../classes/Scene.dart';
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
        position: randomItem(scene.spawnPointPlayers)
    );
    player.z = 48.0;
    player.x = 300;
    player.y = 300;
    return player;
  }

  @override
  bool get full => false;
}