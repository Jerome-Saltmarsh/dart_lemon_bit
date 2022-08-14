

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';

Json toJsonGameObject(GameObject gameObject){
  return {
    'x': gameObject.x.toInt(),
    'y': gameObject.y.toInt(),
    'z': gameObject.z.toInt(),
    'type': gameObject.type,
  };
}