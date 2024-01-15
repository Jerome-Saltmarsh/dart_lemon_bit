
import '../../src.dart';

class WitchesLair2 extends AmuletGame {

  late AmuletNpcWitch npcWitch;

  WitchesLair2({
    required super.amulet,
    required super.scene,
    required super.time,
    required super.environment,
  }) : super (
    name: 'Witches lair 2',
    amuletScene: AmuletScene.Witches_Lair_2
  ) {
    final indexSpawnWitch = scene.getKey('spawn_witch');

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
      ..helmType = HelmType.Pointed_Hat;

    characters.add(npcWitch);
  }

  @override
  void customOnCharacterKilled(Character target, src) {
    super.customOnCharacterKilled(target, src);

    if (target == npcWitch && src is AmuletPlayer) {
      src.completeQuestMain(QuestMain.Kill_The_Witch);
      src.writePlayerEvent(PlayerEvent.Game_Finished);
    }
  }

  @override
  void updateCharacterAction(Character character) {
    if (character.deadInactiveOrBusy) {
      return;
    }

    final target = character.target;
    if (character is AmuletNpcWitch && target != null){
       // final itemSlotPower = character.itemSlotPower;
       // final powerAmuletItem = itemSlotPower.amuletItem;
       // if (powerAmuletItem != null && !itemSlotPower.chargesEmpty){
       //    final powerStats = character.getAmuletItemStats(powerAmuletItem);
       //    if (powerStats != null) {
       //      if (character.withinRadiusPosition(target, powerStats.range)) {
       //        character.activateItemSlotPower();
       //        character.facePosition(target);
       //        character.itemSlotPower.reduceCharges();
       //        character.setCharacterStateCasting(
       //          duration: 35,
       //        );
       //      }
       //    }
       // }
    }
    super.updateCharacterAction(character);
  }
}


