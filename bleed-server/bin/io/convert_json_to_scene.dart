
import 'dart:convert';

import 'package:typedef/json.dart';

import '../classes/gameobject.dart';
import '../classes/library.dart';
import '../classes/node.dart';
import '../common/game_object_type.dart';
import '../common/node_orientation.dart';
import '../common/node_type.dart';
import '../common/spawn_type.dart';
import '../isometric/generate_node.dart';

Scene convertStringToScene(String value, String name){
  return convertJsonToScene(jsonDecode(value), name);
}

Scene convertJsonToScene(Json json, String name) {
  final height = json.getInt('grid-z');
  final rows = json.getInt('grid-rows');
  final columns = json.getInt('grid-columns');
  final List jsonGameObjects = json['gameobjects'] ?? [];

  return Scene(
    name: name,
    grid: convertFlatGridToGrid(json['grid'], height, rows, columns),
    gameObjects: jsonGameObjects.map(convertDynamicToGameObject).toList(),
  );
}

GameObject convertDynamicToGameObject(dynamic value) {
  if (value is Json) return convertJsonToGameObject(value);
  throw Exception("Cannot convert value to gameobject");
}

int? tryGetInt(Json json, String fieldName){
  final value = json[fieldName];
  if (value == null) return null;
  if (value is int) return value;
  if (value is String){
    return int.tryParse(value);
  }
  return null;
}

double? tryGetDouble(Json json, String fieldName){
  final value = json[fieldName];
  if (value == null) return null;
  if (value is double) return value;
  if (value is String){
    return double.tryParse(value);
  }
  return null;
}

const teamGood = 1;
const teamBad = 1;
const teamDefault = teamBad;

GameObject convertJsonToGameObject(Json json) {
    final type = json.getInt('type');
    final x = json.getDouble('x');
    final y = json.getDouble('y');
    final z = json.getDouble('z');

    if (type == GameObjectType.Spawn) {
      final spawnType = json.containsKey('spawn-type')
          ? json.getInt('spawn-type')
          : SpawnType.Chicken;
      return GameObjectSpawn(
          x: x,
          y: y,
          z: z,
          spawnType: spawnType,
          spawnRadius: tryGetDouble(json, 'spawn-radius') ?? 50,
          spawnAmount: tryGetInt(json, 'spawn-amount') ?? 1,
      );
    }

    if (GameObjectType.isStatic(type)) {
      return GameObjectStatic(
        x: x,
        y: y,
        z: z,
        type: type,
      );
    }

    switch (type) {
      case GameObjectType.Chicken:
        return GameObjectChicken(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Jellyfish:
        return GameObjectJellyfish(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Jellyfish_Red:
        return GameObjectJellyfishRed(
          x: x,
          y: y,
          z: z,
        );
      case GameObjectType.Butterfly:
        return GameObjectButterfly(
          x: x,
          y: y,
          z: z,
        );
      default:
        throw Exception("Could not create gameobject from type $type");
    }
}

List<List<List<Node>>> convertFlatGridToGrid(List<dynamic> flatGrid, int height, int rows, int columns){
  var index = 0;
  final List<List<List<Node>>> grid = List.generate(height, (zIndex) {
    return List.generate(rows, (rowIndex){
      return List.generate(columns, (columnIndex){
        final node = generateNode(flatGrid[index]);
        if (node is NodeOriented){
          index++;
          node.orientation = flatGrid[index];

          if (node.orientation == NodeOrientation.None) {
             node.orientation = NodeType.getDefaultOrientation(node.type);
          }
        }
        index++;
        return node;
      });
    });
  });
  return grid;
}
