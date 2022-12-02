
import 'dart:convert';
import 'dart:typed_data';

import 'package:typedef/json.dart';
import 'package:bleed_server/gamestream.dart';

Scene convertStringToScene(String value, String name) =>
  convertJsonToScene(json.decode(value), name);

Scene convertJsonToScene(Json json, String name) {
  final height = json.getInt('grid-z');
  final rows = json.getInt('grid-rows');
  final columns = json.getInt('grid-columns');
  final total = height * rows * columns;
  final List jsonGameObjects = json['gameobjects'] ?? [];
  final nodeTypesDynamic = (json['grid-types'] as List);
  final nodeOrientations = (json['grid-orientations'] as List);
  final nodeTypes = Uint8List(total);
  final nodeOrientation = Uint8List(total);
  final spawnNodesDynamic = json['spawn-nodes'];
  assert (nodeTypesDynamic.length == total);
  final spawnNodes = Uint16List(spawnNodesDynamic == null ? 0 : (spawnNodesDynamic as List).length);

  for (var i = 0; i < spawnNodes.length; i++) {
     spawnNodes[i] = spawnNodesDynamic[i];
  }

  for (var i = 0; i < total; i++) {
    nodeTypes[i] = nodeTypesDynamic[i];
    nodeOrientation[i] = nodeOrientations[i];
  }

  return Scene(
    name: name,
    nodeOrientations: nodeOrientation,
    nodeTypes: nodeTypes,
    gridRows: rows,
    gridHeight: height,
    gridColumns: columns,
    gameObjects: jsonGameObjects.map(convertDynamicToGameObject).toList(),
    spawnPoints: spawnNodes,
    spawnPointTypes: Uint16List(spawnNodes.length),
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

GameObject convertJsonToGameObject(Json json) =>
    GameObject(
        x: json.getDouble('x'),
        y: json.getDouble('y'),
        z: json.getDouble('z'),
        type: json.getInt('type'),
    );


