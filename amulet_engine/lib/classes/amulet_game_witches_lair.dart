
import '../src.dart';

class AmuletGameWitchesLair extends AmuletGame {

  late AmuletNpc npcWitch;

  AmuletGameWitchesLair({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
  }) : super (
    name: 'Witches lair',
    amuletScene: AmuletScene.Witches_Lair
  ) {
    final indexSpawnWitch = scene.getKey('spawn_witch');
    npcWitch = AmuletNpc(
        health: 200,
        weaponType: 0,
        team: AmuletTeam.Monsters,
        weaponDamage: 1,
        weaponRange: 1,
        weaponCooldown: 1,
        x: scene.getIndexX(indexSpawnWitch),
        y: scene.getIndexY(indexSpawnWitch),
        z: scene.getIndexZ(indexSpawnWitch),
        name: 'WITCH',
        attackDuration: 1,
    );
    characters.add(npcWitch);
  }
}