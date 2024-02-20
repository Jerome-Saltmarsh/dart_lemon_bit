
import 'package:amulet_engine/isometric/classes/gameobject.dart';
import 'package:amulet_engine/isometric/classes/scene.dart';
import 'package:amulet_engine/isometric/instances/encoder.dart';
import 'package:lemon_json/src.dart';

Json writeSceneToJson(Scene scene){
  final json = Json();
  json['name'] = scene.name;
  json['rows'] = scene.rows;
  json['columns'] = scene.columns;
  json['height'] = scene.height;
  json['node_types'] = encoder.encode(scene.nodeTypes);
  json['node_orientations'] = encoder.encode(scene.nodeOrientations);
  json['variations'] = encoder.encode(scene.variations);
  json['marks'] = scene.marks;
  json['keys'] = scene.keys;
  json['locations'] = scene.locations;
  json['gameobjects'] = writeGameObjectsToJson(scene.gameObjects);
  return json;
}

List<Json> writeGameObjectsToJson(List<GameObject> gameObjects){
  final list = <Json>[];
  for (final gameObject in gameObjects){
    if (!gameObject.persistable) continue;
    list.add(writeGameObjectToJson(gameObject));
  }
  return list;
}

Json writeGameObjectToJson(GameObject gameObject){
  final json = Json();
  json['x'] = gameObject.x.toInt();
  json['y'] = gameObject.y.toInt();
  json['z'] = gameObject.z.toInt();
  json['item_type'] = gameObject.itemType;
  json['sub_type'] = gameObject.subType;
  json['deactive_timer'] = gameObject.deactivationTimer;
  json['team'] = gameObject.team;
  json['id'] = gameObject.id;
  return json;
}
