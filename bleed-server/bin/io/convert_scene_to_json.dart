
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

Uint8List convertNodesToByteArray(List<List<List<Node>>> nodes) {
  final height = nodes.length;
  final rows = nodes[0].length;
  final columns = nodes[0][0].length;
  final bytes = Uint8List(height * rows * columns);
  var i = 0;
  for (final z in nodes) {
    for(final row in z) {
      for (final column in row) {
        bytes[i] = column.type;
        i++;
      }
    }
  }
  return bytes;
}