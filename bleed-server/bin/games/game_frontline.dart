

import 'package:lemon_math/library.dart';

import '../classes/Game.dart';
import '../classes/Player.dart';
import '../common/weapon_type.dart';
import '../scene_generator.dart';

class GameFrontline extends Game {

  GameFrontline() : super(
    generateRandomScene(
      columns: 150,
      rows: 150,
      seed: random.nextInt(2000),
    ),
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