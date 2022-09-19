

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../classes/node.dart';
import '../common/game_waves_response.dart';
import '../common/library.dart';
import '../common/teams.dart';
import '../dark_age/dark_age_scenes.dart';

class GameWaves extends Game {

  static const framesBetweenRounds = 1000;

  var timer = framesBetweenRounds;
  var remaining = 0;

  GameWaves() : super(darkAgeScenes.dungeon_1);

  @override
  int getTime() => 0;

  @override
  Player spawnPlayer() {
    final player = Player(game: this, weapon: buildWeaponUnarmed());
    player.points = 5;
    player.weaponSlot1 = buildWeaponUnarmed();
    player.weaponSlot2 = buildWeaponUnarmed();
    player.weaponSlot3 = buildWeaponUnarmed();
    player.setCharacterStateSpawning();

    perform((){

      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.clear_upgrades);

      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.purchase_primary);
      player.writeByte(AttackType.Assault_Rifle);
      player.writeInt(20);

      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.purchase_primary);
      player.writeByte(AttackType.Rifle);
      player.writeInt(20);

      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.purchase_secondary);
      player.writeByte(AttackType.Handgun);
      player.writeInt(5);

      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.purchase_tertiary);
      player.writeByte(AttackType.Blade);
      player.writeInt(20);

    }, 1);


    return player;
  }

  @override
  void customUpdate() {
    if (timer <= 0) return;
    timer--;

    for (final player in players) {
      player.writeByte(ServerResponse.Game_Waves);
      player.writeByte(GameWavesResponse.timer);
      player.writePercentage(timer / framesBetweenRounds);
    }

    if (timer == 0)
      spawnCreeps();

  }

  void spawnCreeps(){
    for (final row in scene.grid) {
      for (final column in row) {
        for (final node in column){
          if (node is NodeSpawn) {
            remaining++;
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
    if (target is AI) {
      remaining--;
      spawnGameObjectLoot(
        x: target.x,
        y: target.y,
        z: target.z,
        type: 0,
      );

      if (remaining == 0){
        timer = framesBetweenRounds;
      }
    }
  }

  @override
  void customOnPlayerCollisionWithLoot(Player player, GameObjectLoot loot){
    deactivateGameObject(loot);
    player.experience++;
    player.points++;
    player.writePoints();
    player.dispatchEventLootCollected();
  }

  @override
  void customOnPlayerRequestPurchaseWeapon(Player player, int type) {
    if (timer == 0) return;

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

  @override
  int get gameType => GameType.Waves;
}