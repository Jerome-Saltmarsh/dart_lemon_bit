
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
  static const keySpawnMay = 'spawn_may';
  static const keySpawnTraveller = 'spawn_traveller';
  late AmuletNpc npcWarren;
  late AmuletNpc npcGuard1;
  late AmuletNpc npcGuard2;
  late AmuletNpc npcMay;
  late AmuletNpc npcTraveller;
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
    final indexSpawnMay = scene.getKey(keySpawnMay);
    final indexSpawnTraveller = scene.getKey(keySpawnTraveller);

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

    npcMay = AmuletNpc(
      x: scene.getIndexX(indexSpawnMay),
      y: scene.getIndexY(indexSpawnMay),
      z: scene.getIndexZ(indexSpawnMay),
      health: 50,
      invincible: true,
      team: AmuletTeam.Human,
      weaponType: WeaponType.Bow,
      weaponCooldown: 3,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: "May",
    )
      ..fixed = true
      ..invincible = true
      ..helmType = HelmType.None
      ..hairType = 2
      ..hairColor = 30
      ..bodyType = BodyType.Shirt_Blue
      ..legsType = LegType.Leather
      ..handTypeLeft = HandType.None
      ..weaponType = WeaponType.Unarmed
      ..gender = Gender.female
      ..interact = onInteractWithMay
      ..complexion = ComplexionType.fair;

    npcTraveller = AmuletNpc(
      x: scene.getIndexX(indexSpawnTraveller),
      y: scene.getIndexY(indexSpawnTraveller),
      z: scene.getIndexZ(indexSpawnTraveller),
      health: 50,
      invincible: true,
      team: AmuletTeam.Human,
      weaponType: WeaponType.Bow,
      weaponCooldown: 3,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: 'Mysterious-Traveller',
    )
      ..fixed = true
      ..invincible = true
      ..helmType = HelmType.Wizard_Hat
      ..hairType = 1
      ..hairColor = 20
      ..bodyType = BodyType.Leather_Armour
      ..legsType = LegType.Leather
      ..handTypeLeft = HandType.None
      ..weaponType = WeaponType.Staff
      ..gender = Gender.male
      ..interact = onInteractWithTraveller
      ..complexion = 10;

    characters.add(npcWarren);
    characters.add(npcGuard1);
    characters.add(npcGuard2);
    characters.add(npcMay);
    characters.add(npcTraveller);
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

  void onInteractWithMay(AmuletPlayer player, AmuletNpc may){
    switch (player.questMain){
      case QuestMain.Speak_With_Warren:
        player.talk(
            may,
              'Welcome to the Inn.'
              'If you are looking for something to do, try speaking wth Warren.'
        );
        break;
      case QuestMain.Kill_The_Witch:
        player.talk(may, 'Rumor has it the witch that has been terrorizing our village lives in some greater castle somewhere to the north');
        break;
      case QuestMain.Return_To_Warren:
        player.talk(may, 'Wow you really managed to kill her? I bet Warren would like to thank you.');
        break;
      case QuestMain.Completed:
        player.talk(may, 'Welcome back to the Inn.');
        break;
    }
  }

  void onInteractWithTraveller(AmuletPlayer player, AmuletNpc npc){
    switch (player.questMain){
      case QuestMain.Speak_With_Warren:
        player.talk(
            npc, 'Leave me.'
        );
        break;
      case QuestMain.Kill_The_Witch:
        player.talk(npc, '...');
        break;
      case QuestMain.Return_To_Warren:
        player.talk(npc, 'You defeated the Witch. I am impressed. Perhaps there is something you could help me with');
        break;
      case QuestMain.Completed:
        player.talk(npc, 'Our business is concluded');
        break;
    }
  }

}

