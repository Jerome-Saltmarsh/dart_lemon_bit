

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';

Json convertGameObjectToJson(GameObject gameObject) {
  if (gameObject is GameObjectAnimal)
    return toJsonGameObjectAnimal(gameObject);

  return {
    'x': gameObject.x.toInt(),
    'y': gameObject.y.toInt(),
    'z': gameObject.z.toInt(),
    'type': gameObject.type,
  };
}

Json toJsonGameObjectAnimal(GameObjectAnimal gameObject) => {
      'x': gameObject.spawnX.toInt(),
      'y': gameObject.spawnY.toInt(),
      'z': gameObject.spawnZ.toInt(),
      'type': gameObject.type,
      'radius': gameObject.wanderRadius.toInt(),
    };