

import '../classes/game.dart';
import '../classes/player.dart';
import '../classes/weapon.dart';
import '../dark_age/dark_age_scenes.dart';

class GameWaves extends Game {

  GameWaves() : super(darkAgeScenes.dungeon_1);

  @override
  int getTime() => 0;

  @override
  Player spawnPlayer() {
    return Player(game: this, weapon: buildWeaponUnarmed());
  }
}