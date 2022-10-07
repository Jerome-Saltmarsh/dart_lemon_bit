
import 'dart:convert';

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';
import '../classes/scene.dart';
import '../common/game_object_type.dart';
import 'convert_gameobject_to_json.dart';


String convertSceneToString(Scene scene) =>
   jsonEncode(convertSceneToJson(scene));

Json convertSceneToJson(Scene scene) => Json()..
  ['grid-z'] = scene.gridHeight..
  ['grid-rows'] = scene.gridRows..
  ['grid-columns'] = scene.gridColumns..
  ['grid-types'] = scene.nodeTypes..
  ['grid-orientations'] = scene.nodeOrientations..
  ['gameobjects'] = scene.gameObjects
    .where(isPersistable)
    .map(convertGameObjectToJson)
    .toList();

bool isPersistable(GameObject gameObject) =>
    GameObjectType.isPersistable(gameObject.type);