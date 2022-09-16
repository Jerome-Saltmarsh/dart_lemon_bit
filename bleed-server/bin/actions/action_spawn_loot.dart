

import '../classes/game.dart';
import '../classes/gameobject.dart';
import '../common/library.dart';

void actionSpawnLoot({
  required Game game,
  required double x,
  required double y,
  required double z,
}){
  game.gameObjects.add(
      GameObjectLoot(
          x: x,
          y: y,
          z: z + tileHeightHalf,
          lootType: 0,
      )
  );
}