

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';

Json toJsonGameObject(GameObject gameObject) {
  if (gameObject is GameObjectAnimal)
    return toJsonGameObjectAnimal(gameObject);

  return {
    'x': gameObject.x.toInt(),
    'y': gameObject.y.toInt(),
    'z': gameObject.z.toInt(),
    'type': gameObject.type,
    if (gameObject is GameObjectSpawn)
       'spawn-type': gameObject.spawnType,
  };
}

class SpawnType {
  static const Zombie = 0;
  static const Chicken = 0;
  static const Butterfly = 0;
}

Json toJsonGameObjectAnimal(GameObjectAnimal gameObject) => {
      'x': gameObject.spawnX.toInt(),
      'y': gameObject.spawnY.toInt(),
      'z': gameObject.spawnZ.toInt(),
      'type': gameObject.type,
      'radius': gameObject.wanderRadius.toInt(),
    };