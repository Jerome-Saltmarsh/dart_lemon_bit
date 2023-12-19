
import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/quests/quest_main.dart';

import '../packages/src.dart';
import 'amulet_game.dart';
import 'amulet_npc.dart';
import 'amulet_player.dart';

class AmuletGameWorld0101 extends AmuletGame {

  static const keySpawnWarren = 'spawn_warren';

  final chanceOfDropItemOnGrassCut = 0.25;
  final gameObjectDeactivationTimer = 5000;
  final enemyRespawnDuration = 30; // in seconds

  final playerSpawnX = 2030.0;
  final playerSpawnY = 2040.0;
  final playerSpawnZ = 25.0;

  var cooldownTimer = 0;

  late AmuletNpc npcWarren;

  AmuletGameWorld0101({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
    required super.name,
  }) : super(amuletScene: AmuletScene.Town){

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
