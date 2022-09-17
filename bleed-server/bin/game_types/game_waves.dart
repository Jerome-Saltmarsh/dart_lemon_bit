

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../classes/node.dart';
import '../common/game_waves_response.dart';
import '../common/library.dart';
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

    for (final player in players) {
      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.timer);
      player.writeInt(timer);
    }

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

  @override
  void customOnCharacterKilled(Character target, dynamic src) {
    spawnGameObjectLoot(
        x: target.x,
        y: target.y,
        z: target.z,
        type: 0,
    );
  }

  @override
  void customOnCollisionBetweenColliders(Collider a, Collider b) {
    if (a is Player && b is GameObjectLoot) {
      return onCollisionBetweenPlayerAndGameObjectLoot(a, b);
    }
    if (a is GameObjectLoot && b is Player) {
      return onCollisionBetweenPlayerAndGameObjectLoot(b, a);
    }
  }

  void onCollisionBetweenPlayerAndGameObjectLoot(Player player, GameObjectLoot loot){
    deactivateGameObject(loot);
    player.health++;
    player.experience++;
    player.weaponSlot1.rounds++;
    player.weaponSlot2.rounds++;
    player.weaponSlot3.rounds++;
    player.dispatchEventLootCollected();
  }

}