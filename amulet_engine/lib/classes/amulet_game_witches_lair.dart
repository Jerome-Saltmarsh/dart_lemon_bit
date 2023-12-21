
import 'package:amulet_engine/classes/amulet_npcs/amulet_npc_witch.dart';

import '../src.dart';

class AmuletGameWitchesLair extends AmuletGame {

  late AmuletNpcWitch npcWitch;
  late GameObject entrance;

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
    final indexEntrance = scene.getKey('entrance');

    npcWitch = AmuletNpcWitch(
        x: scene.getIndexX(indexSpawnWitch),
        y: scene.getIndexY(indexSpawnWitch),
        z: scene.getIndexZ(indexSpawnWitch),
    )
      ..complexion = ComplexionType.fair
      ..bodyType = BodyType.Shirt_Blue
      ..legsType = LegType.Leather
      ..shoeType = ShoeType.Iron_Plates
      ..handTypeLeft = HandType.Gauntlets
      ..hairType = HairType.basic_2
      ..hairColor = 17
      ..helmType = HelmType.Wizard_Hat;

    characters.add(npcWitch);

    entrance = spawnGameObjectAtIndex(
        index: indexEntrance,
        type: ItemType.Object,
        subType: GameObjectType.Interactable,
        team: TeamType.Neutral,
    )..interactable = true;
  }

  @override
  void customOnCharacterInteractWithGameObject(Character character, GameObject gameObject) {
    if (character is! AmuletPlayer){
      return;
    }
    if (gameObject == entrance) {
      amulet.playerChangeGame(
          player: character,
          target: amulet.amuletGameWorld11,
          sceneKey: 'spawn_player',
      );
    }
  }

  @override
  void customOnCharacterKilled(Character target, src) {
    super.customOnCharacterKilled(target, src);

    if (target == npcWitch && src is AmuletPlayer){
      src.completeQuestMain(QuestMain.Kill_The_Witch);
    }
  }

  @override
  void updateCharacterAction(Character character) {
    if (character is AmuletNpcWitch){
       final target = character.target;
       if (target != null) {
          // character.itemSlotPowerActive = false;
          if (character.itemSlotPower.charges > 0){
            final itemSlotPower = character.itemSlotPower;
            final itemTypePower = itemSlotPower.amuletItem;
            if (itemTypePower != null) {
              final powerLevel = itemTypePower.getLevel(
                  fire: character.elementFire,
                  water: character.elementWater,
                  electricity: character.elementElectricity,
              );
              if (powerLevel != -1){
                final powerStats = itemTypePower.getStatsForLevel(powerLevel);
                if (powerStats != null){
                  if (character.withinRadiusPosition(target, powerStats.range)) {
                    character.itemSlotPowerActive = true;
                    character.setCharacterStateCasting(
                        duration: powerStats.performDuration,
                    );
                  }
                }
              }
            }
          }

       }
    }
    super.updateCharacterAction(character);
  }
}


