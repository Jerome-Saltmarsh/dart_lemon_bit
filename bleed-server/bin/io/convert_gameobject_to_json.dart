

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';

Json convertGameObjectToJson(GameObject gameObject) {
  if (gameObject is GameObjectAnimal)
    return toJsonGameObjectAnimal(gameObject);

  if (gameObject is GameObjectSpawn)
    return convertGameObjectSpawnToJson(gameObject);

  return {
    'x': gameObject.x.toInt(),
    'y': gameObject.y.toInt(),
    'z': gameObject.z.toInt(),
    'type': gameObject.type,
  };
}

Json convertGameObjectSpawnToJson(GameObjectSpawn gameObject){
  return {
    'x': gameObject.x.toInt(),
    'y': gameObject.y.toInt(),
    'z': gameObject.z.toInt(),
    'type': gameObject.type,
    'spawn-type': gameObject.spawnType,
    'spawn-amount': gameObject.spawnAmount,
    'spawn-radius': gameObject.spawnRadius,
  };
}

Json toJsonGameObjectAnimal(GameObjectAnimal gameObject) => {
      'x': gameObject.spawnX.toInt(),
      'y': gameObject.spawnY.toInt(),
      'z': gameObject.spawnZ.toInt(),
      'type': gameObject.type,
      'radius': gameObject.wanderRadius.toInt(),
    };