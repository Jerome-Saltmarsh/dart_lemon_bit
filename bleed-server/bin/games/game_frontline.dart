

import 'package:lemon_math/library.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/weapon_type.dart';
import '../scene_generator.dart';

class GameFrontline extends Game {

  GameFrontline() : super(
    generateScenePlain()
  ){
    scene.generateStairs();
  }

  @override
  int getTime() {
    return 12 * 60 * 60;
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