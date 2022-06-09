

import 'package:lemon_math/library.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/weapon_type.dart';
import '../scene_generator.dart';

class GameFrontline extends Game {

  var time = 12 * 60 * 60;

  GameFrontline() : super(
    generateScenePlain()
  );

  @override
  int getTime() {
    return time;
  }

  @override
  Player spawnPlayer() {
    return Player(
        game: this,
        weapon: WeaponType.Shotgun,
        position: randomItem(scene.spawnPointPlayers)
    );
  }

  @override
  bool get full => false;
}