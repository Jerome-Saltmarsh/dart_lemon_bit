

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
    final player = Player(game: this, weapon: buildWeaponUnarmed());
    player.weaponSlot1 = buildWeaponUnarmed();
    player.weaponSlot2 = buildWeaponUnarmed();
    player.weaponSlot3 = buildWeaponUnarmed();
    return player;
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
  void customOnPlayerCollisionWithLoot(Player player, GameObjectLoot loot){
    deactivateGameObject(loot);
    player.experience++;
    player.points++;
    player.dispatchEventLootCollected();
  }

  @override
  void handlePlayerRequestPurchaseWeapon(Player player, int type) {
    if (type == AttackType.Assault_Rifle){
       player.weaponSlot1 = buildWeaponAssaultRifle();
    }
    if (type == AttackType.Shotgun){
      player.weaponSlot1 = buildWeaponShotgun();
    }
    if (type == AttackType.Blade){
      player.weaponSlot2 = buildWeaponBlade();
    }
  }
}