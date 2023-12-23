
import 'package:amulet_engine/classes/amulet_game.dart';

import '../../packages/isomeric_engine.dart';
import '../../packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';
import '../amulet_npc.dart';
import '../amulet_player.dart';

class AmuletGameWorld11 extends AmuletGame {

  static const keySpawnWarren = 'spawn_warren';
  static const keySpawnPlayer = 'spawn_player';
  late AmuletNpc npcWarren;
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

    characters.add(npcWarren);
    indexSpawnPlayer = scene.getKey(keySpawnPlayer);
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

