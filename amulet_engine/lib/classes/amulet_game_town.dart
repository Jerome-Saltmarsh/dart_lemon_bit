
import '../packages/src.dart';
import 'amulet_game.dart';
import 'amulet_npc.dart';
import 'amulet_player.dart';
import 'talk_option.dart';

class AmuletGameTown extends AmuletGame {

  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final enemyRespawnDuration = 30; // in seconds

  final playerSpawnX = 2030.0;
  final playerSpawnY = 2040.0;
  final playerSpawnZ = 25.0;

  var cooldownTimer = 0;

  late AmuletNpc npcGuard;

  AmuletGameTown({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required super.name,
  }) : super(amuletScene: AmuletScene.Town){
    characters.add(AmuletNpc(
        x: 2010,
        y: 1760,
        z: 24,
        health: 50,
        team: AmuletTeam.Human,
        weaponType: WeaponType.Unarmed,
        weaponDamage: 1,
        weaponRange: 200,
        weaponCooldown: 30,
        attackDuration: 30,
        name: "Sybil",
        interact: (player, self) {
          player.talk(self, "Hello there", options: [
            TalkOption("Goodbye", endPlayerInteraction),
            TalkOption("Buy", endPlayerInteraction),
          ]);
        }
    )..invincible = true
      ..helmType = HelmType.None
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..complexion = ComplexionType.fair
    );

    npcGuard = AmuletNpc(
      x: 2416,
      y: 1851,
      z: 24,
      health: 200,
      weaponType: WeaponType.Bow,
      weaponRange: 200,
      weaponDamage: 1,
      weaponCooldown: 30,
      attackDuration: 25,
      team: AmuletTeam.Human,
      name: "Guard",
    )
      ..invincible = true
      ..helmType = HelmType.Steel
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..complexion = ComplexionType.fair;

    characters.add(npcGuard);
  }

  @override
  void revive(AmuletPlayer player) {
    super.revive(player);
    movePlayerToSpawnPoint(player);
  }

  void movePlayerToSpawnPoint(AmuletPlayer player) {
    player.setPosition(
      x: 620 + giveOrTake(10),
      y: 523 + giveOrTake(10),
      z: 96,
    );
  }
}
