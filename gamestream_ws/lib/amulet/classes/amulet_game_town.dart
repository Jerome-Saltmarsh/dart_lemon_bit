import 'package:gamestream_ws/amulet.dart';
import 'package:gamestream_ws/packages.dart';

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
    required super.fiendTypes,
  }) {

    spawnFiendsAtSpawnNodes();
    characters.add(AmuletNpc(
        characterType: CharacterType.Kid,
        x: 2010,
        y: 1760,
        z: 24,
        health: 50,
        team: AmuletTeam.Human,
        weaponType: WeaponType.Unarmed,
        weaponDamage: 1,
        weaponRange: 200,
        weaponCooldown: 30,
        name: "Sybil",
        interact: (player) {
          player.talk("Hello there", options: [
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
      characterType: CharacterType.Kid,
      x: 2416,
      y: 1851,
      z: 24,
      health: 200,
      weaponType: WeaponType.Bow,
      weaponRange: 200,
      weaponDamage: 1,
      weaponCooldown: 30,
      team: AmuletTeam.Human,
      name: "Guard",
    )
      ..invincible = true
      ..helmType = HelmType.Steel
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..attackDuration = 30
      ..attackActionFrame = 20
      ..complexion = ComplexionType.fair;

    characters.add(npcGuard);
  }

  @override
  AmuletPlayer buildPlayer() => AmuletPlayer(
    amuletGame: this,
    itemLength: 6,
    x: playerSpawnX,
    y: playerSpawnY,
    z: playerSpawnZ,
  )..level = 1
    ..experience = 0
    ..complexion = ComplexionType.fair;

}
