

import '../../packages/isomeric_engine.dart';
import '../../packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import '../amulet_game.dart';
import '../amulet_npc.dart';
import '../amulet_player.dart';
import '../talk_option.dart';

class AmuletGameWorld11 extends AmuletGame {

  static const keySpawnWarren = 'spawn_warren';
  static const keySpawnSophie = 'spawn_sophie';
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
  late AmuletNpc npcSophie;
  var indexSpawnPlayer = -1;

  AmuletGameWorld11({
    required super.amulet,
  }) : super(
      amuletScene: AmuletScene.World_11,
      name: 'Town',
      time: amulet.amuletTime,
      environment: amulet.amuletEnvironment,
      scene: amulet.scenes.world_11,
  ) {
    indexSpawnPlayer = scene.getKey(keySpawnPlayer);
    final indexSpawnGuard1 = scene.getKey(keySpawnGuard1);
    final indexSpawnGuard2 = scene.getKey(keySpawnGuard2);
    final indexSpawnWarren = scene.getKey(keySpawnWarren);
    final indexSpawnSophie = scene.getKey(keySpawnSophie);
    final indexSpawnMay = scene.getKey(keySpawnMay);
    final indexSpawnTraveller = scene.getKey(keySpawnTraveller);

    npcWarren = AmuletNpc(
      x: scene.getIndexX(indexSpawnWarren),
      y: scene.getIndexY(indexSpawnWarren),
      z: scene.getIndexZ(indexSpawnWarren),
      health: 200,
      team: TeamType.Good,
      weaponType: WeaponType.Unarmed,
      weaponDamage: 0,
      weaponRange: 0,
      attackDuration: 0,
      name: "Gareth",
    )
      ..fixed = true
      ..invincible = true
      ..helmType = HelmType.Full_Helm
      ..armorType = ArmorType.Leather
      ..shoeType = ShoeType.Leather_Boots
      ..interact = onInteractWithGareth
      ..complexion = ComplexionType.fair;

    npcGuard1 = AmuletNpc(
      x: scene.getIndexX(indexSpawnGuard1),
      y: scene.getIndexY(indexSpawnGuard1),
      z: scene.getIndexZ(indexSpawnGuard1),
      health: 50,
      invincible: true,
      team: TeamType.Good,
      weaponType: WeaponType.Bow,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: "Guard",
    )
      ..fixed = false
      ..invincible = true
      ..helmType = HelmType.Leather_Cap
      ..armorType = ArmorType.Leather
      ..shoeType = ShoeType.Grieves
      ..weaponType = WeaponType.Bow
      ..chanceOfSetTarget = 1.0
      ..complexion = ComplexionType.fair;

    npcGuard2 = AmuletNpc(
      x: scene.getIndexX(indexSpawnGuard2),
      y: scene.getIndexY(indexSpawnGuard2),
      z: scene.getIndexZ(indexSpawnGuard2),
      health: 50,
      invincible: true,
      team: TeamType.Good,
      weaponType: WeaponType.Bow,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: "Guard",
    )
      ..fixed = false
      ..invincible = true
      ..helmType = HelmType.Full_Helm
      ..armorType = ArmorType.Leather
      ..weaponType = WeaponType.Bow
      ..shoeType = ShoeType.Grieves
      ..chanceOfSetTarget = 1.0
      ..complexion = ComplexionType.fair;

    npcMay = AmuletNpc(
      x: scene.getIndexX(indexSpawnMay),
      y: scene.getIndexY(indexSpawnMay),
      z: scene.getIndexZ(indexSpawnMay),
      health: 50,
      invincible: true,
      team: TeamType.Good,
      weaponType: WeaponType.Bow,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: "May",
    )
      ..fixed = true
      ..autoTarget = false
      ..invincible = true
      ..helmType = HelmType.None
      ..hairType = 2
      ..hairColor = 30
      ..armorType = ArmorType.Tunic
      ..shoeType = ShoeType.Leather_Boots
      ..weaponType = WeaponType.Unarmed
      ..gender = Gender.female
      ..interact = onInteractWithMay
      ..complexion = ComplexionType.fair;

    npcSophie = AmuletNpc(
      x: scene.getIndexX(indexSpawnSophie),
      y: scene.getIndexY(indexSpawnSophie),
      z: scene.getIndexZ(indexSpawnSophie),
      health: 50,
      invincible: true,
      team: TeamType.Good,
      weaponType: WeaponType.Unarmed,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: "Sophie",
    )
      ..fixed = true
      ..autoTarget = false
      ..invincible = true
      ..helmType = HelmType.None
      ..hairType = 2
      ..hairColor = 30
      ..armorType = ArmorType.Tunic
      ..shoeType = ShoeType.Leather_Boots
      ..weaponType = WeaponType.Unarmed
      ..gender = Gender.female
      ..interact = onInteractWithSophie
      ..complexion = ComplexionType.fair;

    npcTraveller = AmuletNpc(
      x: scene.getIndexX(indexSpawnTraveller),
      y: scene.getIndexY(indexSpawnTraveller),
      z: scene.getIndexZ(indexSpawnTraveller),
      health: 50,
      invincible: true,
      team: TeamType.Good,
      weaponType: WeaponType.Bow,
      weaponDamage: 3,
      weaponRange: 120,
      attackDuration: 30,
      name: 'Mysterious-Traveller',
    )
      ..fixed = true
      ..invincible = true
      ..helmType = HelmType.Pointed_Hat_Black
      ..hairType = 1
      ..hairColor = 20
      ..autoTarget = false
      ..armorType = ArmorType.Leather
      ..shoeType = ShoeType.Leather_Boots
      ..weaponType = WeaponType.Staff
      ..gender = Gender.male
      ..interact = onInteractWithTraveller
      ..complexion = 10;

    characters.add(npcWarren);
    characters.add(npcGuard1);
    characters.add(npcGuard2);
    characters.add(npcMay);
    characters.add(npcTraveller);
    characters.add(npcSophie);
  }

  // Magatha
  void onInteractWithGareth(AmuletPlayer player, AmuletNpc warren){
    switch (player.questMain){
      case QuestMain.Speak_With_Warren:
        player.talk(
            warren,
              'Hello there.'
              'The names Gareth I am the lord of this gloomy old town.'
              'An evil witch has made the forsaken castle in the north her home.'
              'Since then her fowl minions have been scouring the country side.'
              'We would be eternally grateful if you could aid us in defeating her.'
              'Here take this sword.',
            onInteractionOver: () {
              player.questMain = QuestMain.Kill_The_Witch;
              player.acquireAmuletItem(AmuletItem.Weapon_Sword_1_Common);
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

  void onInteractWithSophie(AmuletPlayer player, AmuletNpc npc){
    player.talk(npc, 'how can I help you?', options: [
      TalkOption('FINISH-GAME', (player) {
        player.writePlayerEvent(PlayerEvent.Game_Finished);
      }),
      TalkOption('Learn', (player) {
        player.talk(npc,
            'it would would serve one well to remember that.'
        );
      }),
    ]);

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
            npc, 'The man who calls himself Warren seems to carry a concerned look about him'
        );
        break;
      case QuestMain.Kill_The_Witch:
        player.talk(npc,
            'It is said that the witch lives far to the north in her castle.'
            'with her magics she can change her form.'
            'it seems you have a formidable opponents.'
        );
        break;
      case QuestMain.Return_To_Warren:
        player.talk(npc,
            'You defeated the Witch. I am impressed.'
            'Perhaps there is something you could help me with.'
            'return to me once you have spoken with Warren.'
          ,
        );
        break;
      case QuestMain.Completed:
        player.talk(npc, 'Our business is concluded');
        break;
    }
  }

}

