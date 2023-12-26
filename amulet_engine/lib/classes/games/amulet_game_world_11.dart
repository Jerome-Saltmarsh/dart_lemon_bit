
import 'package:amulet_engine/classes/amulet_game.dart';

import '../../packages/isomeric_engine.dart';
import '../../packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import '../amulet_npc.dart';
import '../amulet_player.dart';

class AmuletGameWorld11 extends AmuletGame {

  static const keySpawnWarren = 'spawn_warren';
  static const keySpawnPlayer = 'spawn_player';
  static const keySpawnGuard1 = 'spawn_guard_1';
  static const keySpawnGuard2 = 'spawn_guard_2';
  late AmuletNpc npcWarren;
  late AmuletNpc npcGuard1;
  late AmuletNpc npcGuard2;
  var indexSpawnPlayer = -1;

  AmuletGameWorld11({
    required super.amulet,
  }) : super(
      amuletScene: AmuletScene.World_11,
      name: AmuletScene.World_11.name,
      time: amulet.amuletTime,
      environment: amulet.amuletEnvironment,
      scene: amulet.scenes.world_11,
  ) {
    indexSpawnPlayer = scene.getKey(keySpawnPlayer);
    final indexSpawnGuard1 = scene.getKey(keySpawnGuard1);
    final indexSpawnGuard2 = scene.getKey(keySpawnGuard2);
    final indexSpawnWarren = scene.getKey(keySpawnWarren);

    npcWarren = AmuletNpc(
      x: scene.getIndexX(indexSpawnWarren),
      y: scene.getIndexY(indexSpawnWarren),
      z: scene.getIndexZ(indexSpawnWarren),
      health: 200,
      team: AmuletTeam.Human,
      weaponType: WeaponType.Unarmed,
      weaponCooldown: 0,
      weaponDamage: 0,
      weaponRange: 0,
      attackDuration: 0,
      name: "Warren",
    )
      ..fixed = true
      ..invincible = true
      ..helmType = HelmType.Steel
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..interact = onInteractWithWarren
      ..complexion = ComplexionType.fair;

    npcGuard1 = AmuletNpc(
      x: scene.getIndexX(indexSpawnGuard1),
      y: scene.getIndexY(indexSpawnGuard1),
      z: scene.getIndexZ(indexSpawnGuard1),
      health: 50,
      invincible: true,
      team: AmuletTeam.Human,
      weaponType: WeaponType.Bow,
      weaponCooldown: 3,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: "Guard",
    )
      ..fixed = true
      ..invincible = true
      ..helmType = HelmType.Steel
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..handTypeLeft = HandType.Leather_Gloves
      ..weaponType = WeaponType.Bow
      ..complexion = ComplexionType.fair;

    npcGuard2 = AmuletNpc(
      x: scene.getIndexX(indexSpawnGuard2),
      y: scene.getIndexY(indexSpawnGuard2),
      z: scene.getIndexZ(indexSpawnGuard2),
      health: 50,
      invincible: true,
      team: AmuletTeam.Human,
      weaponType: WeaponType.Bow,
      weaponCooldown: 3,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: "Guard",
    )
      ..fixed = true
      ..invincible = true
      ..helmType = HelmType.Steel
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..handTypeLeft = HandType.Leather_Gloves
      ..weaponType = WeaponType.Bow
      ..complexion = ComplexionType.fair;

    characters.add(npcWarren);
    characters.add(npcGuard1);
    characters.add(npcGuard2);
  }

  void onInteractWithWarren(AmuletPlayer player, AmuletNpc warren){
    switch (player.questMain){
      case QuestMain.Speak_With_Warren:
        player.talk(
            warren,
              'Hello stranger.'
              'Expect but little kindness from the people of this village.'
              'There is an evil witch who has been terrorizing us.'
              'Her fowl minions are a constant threat.'
              'I suspect her lair is somewhere in the spooky woods.'
              'But I have not the courage to go there myself.',
            onInteractionOver: (){
              player.questMain = QuestMain.Kill_The_Witch;
            }
        );
        break;
      case QuestMain.Kill_The_Witch:
        player.talk(warren, 'the witches lair is somewhere within the spooky woods');
        break;
      case QuestMain.Return_To_Warren:
        player.talk(warren, 'you killed her! I cannot believe it. Finally we are free of her curse.');
        break;
      case QuestMain.Completed:
        player.talk(warren, 'hello friend.');
        break;
    }
  }

}

