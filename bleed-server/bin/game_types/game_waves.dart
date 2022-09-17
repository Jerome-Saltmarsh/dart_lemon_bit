

import '../classes/game.dart';
import '../classes/node.dart';
import '../classes/player.dart';
import '../classes/weapon.dart';
import '../common/teams.dart';
import '../dark_age/dark_age_scenes.dart';

class GameWaves extends Game {

  var timer = 300;

  GameWaves() : super(darkAgeScenes.dungeon_1);

  @override
  int getTime() => 0;

  @override
  Player spawnPlayer() {
    return Player(game: this, weapon: buildWeaponUnarmed());
  }

  @override
  void customUpdate() {
    if (timer <= 0) return;
    timer--;
    if (timer > 0) return;

    for (final row in scene.grid) {
       for (final column in row) {
          for (final node in column){
             if (node is NodeSpawn) {
                spawnZombie(
                    x: node.x,
                    y: node.y,
                    z: node.z,
                    health: 2,
                    team: Teams.evil,
                    damage: 1,
                );
             }
          }
       }
    }

  }
}