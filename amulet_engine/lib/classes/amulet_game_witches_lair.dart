
import '../src.dart';

class AmuletGameWitchesLair extends AmuletGame {

  late AmuletNpc npcWitch;
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

    npcWitch = AmuletNpc(
        health: 200,
        team: AmuletTeam.Monsters,
        weaponRange: 200,
        weaponDamage: 5,
        weaponCooldown: 15,
        attackDuration: 30,
        weaponType: WeaponType.Staff,
        x: scene.getIndexX(indexSpawnWitch),
        y: scene.getIndexY(indexSpawnWitch),
        z: scene.getIndexZ(indexSpawnWitch),
        name: 'WITCH',
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
}