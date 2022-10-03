
import 'dart:convert';

import 'package:typedef/json.dart';

import '../classes/node.dart';
import '../classes/scene.dart';
import '../common/node_orientation.dart';
import '../common/node_type.dart';
import 'convert_gameobject_to_json.dart';


String convertSceneToString(Scene scene) =>
   jsonEncode(convertSceneToJson(scene));

Json convertSceneToJson(Scene scene) {
  final json = Json();
  json['grid-z'] = scene.gridHeight;
  json['grid-rows'] = scene.gridRows;
  json['grid-columns'] = scene.gridColumns;
  /// TODO
  // json['grid'] = convertNodesToByteArray(scene.grid);
  json['gameobjects'] = scene.gameObjects
      .where((gameObject) => gameObject.persist)
      .map(convertGameObjectToJson)
      .toList();
  return json;
}