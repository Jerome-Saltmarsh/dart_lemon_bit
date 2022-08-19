
import 'dart:convert';
import 'dart:typed_data';

import 'package:typedef/json.dart';

import '../classes/node.dart';
import '../classes/scene.dart';
import 'to_json_gameobject.dart';


String convertSceneToString(Scene scene) {
   return jsonEncode(convertSceneToJson(scene));
}

Json convertSceneToJson(Scene scene) {
  final json = Json();
  json['grid-z'] = scene.gridHeight;
  json['grid-rows'] = scene.gridRows;
  json['grid-columns'] = scene.gridColumns;
  json['grid'] = convertNodesToByteArray(scene.grid);
  json['gameobjects'] = scene.gameObjects
      .where((gameObject) => gameObject.persist)
      .map(toJsonGameObject)
      .toList();
  return json;
}

List<int> convertNodesToByteArray(List<List<List<Node>>> nodes) {
  final bytes = <int>[];
  for (final z in nodes) {
    for(final row in z) {
      for (final node in row) {
        bytes.add(node.type);
        if (node is NodeOriented) {
          bytes.add(node.orientation);
        }
      }
    }
  }
  return bytes;
}