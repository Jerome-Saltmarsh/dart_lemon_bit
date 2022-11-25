

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';

Json convertGameObjectToJson(GameObject gameObject) => {
  'x': gameObject.x.toInt(),
  'y': gameObject.y.toInt(),
  'z': gameObject.z.toInt(),
  'type': gameObject.type,
};
