
import 'dart:convert';

import 'package:typedef/json.dart';

import '../classes/node.dart';
import '../classes/scene.dart';
import '../common/node_orientation.dart';
import '../common/node_type.dart';
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

        if (node.type == NodeType.Bricks){
          bytes.add(NodeType.Brick_2);
          bytes.add(NodeOrientation.Solid);
          continue;
        }

        if (node.type == NodeType.Wood){
          bytes.add(NodeType.Wood_2);
          bytes.add(NodeOrientation.Solid);
          continue;
        }

        if (node.type == NodeType.Grass){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Solid);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_North){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_North);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_East){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_East);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_South){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_South);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_West){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_West);
          continue;
        }

        if (node.type == NodeType.Grass_Edge_Bottom){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Inner_North_East);
          continue;
        }

        if (node.type == NodeType.Grass_Edge_Left){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Inner_South_East);
          continue;
        }

        if (node.type == NodeType.Grass_Edge_Top){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Inner_South_West);
          continue;
        }

        if (node.type == NodeType.Grass_Edge_Right){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Inner_North_West);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_Top){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Outer_North_East);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_Left){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Outer_South_East);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_Bottom){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Outer_South_West);
          continue;
        }

        if (node.type == NodeType.Grass_Slope_Right){
          bytes.add(NodeType.Grass_2);
          bytes.add(NodeOrientation.Slope_Outer_North_West);
          continue;
        }

        bytes.add(node.type);

        if (node is NodeOriented) {
          bytes.add(node.orientation);
        }
      }
    }
  }
  return bytes;
}