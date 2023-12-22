
import 'package:amulet_engine/classes/amulet_game.dart';

import '../../packages/isomeric_engine.dart';

class AmuletGameWorld11 extends AmuletGame {

  // late GameObject doorway;

  AmuletGameWorld11({
    required super.amulet,
  }) : super(
      amuletScene: AmuletScene.World_11,
      name: AmuletScene.World_11.name,
      time: amulet.amuletTime,
      environment: amulet.amuletEnvironment,
      scene: amulet.scenes.world_11,
  ) {
    // final indexCastleEntrance = scene.getKey('castle_entrance');

    // doorway = spawnGameObjectAtIndex(
    //     index: indexCastleEntrance,
    //     type: ItemType.Object,
    //     subType: GameObjectType.Interactable,
    //     team: 0,
    // )
    //   ..persistable = false
    //   ..interactable = true;
  }

  // @override
  // void customOnCharacterInteractWithGameObject(Character character, GameObject gameObject) {
  //   if (character is! AmuletPlayer){
  //     return;
  //   }
  //   if (gameObject == doorway) {
  //      amulet.playerChangeGame(
  //          player: character,
  //          target: amulet.amuletGameWitchesLair1,
  //          sceneKey: 'spawn_player',
  //      );
  //   }
  // }
}