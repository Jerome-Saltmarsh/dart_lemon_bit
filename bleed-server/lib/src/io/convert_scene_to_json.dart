import 'package:bleed_server/gamestream.dart';
import 'dart:convert';

import 'package:typedef/json.dart';

import 'convert_gameobject_to_json.dart';


String convertSceneToString(Scene scene) =>
   jsonEncode(convertSceneToJson(scene));

Json convertSceneToJson(Scene scene) => Json()..
  ['grid-z'] = scene.gridHeight..
  ['grid-rows'] = scene.gridRows..
  ['grid-columns'] = scene.gridColumns..
  ['grid-types'] = scene.nodeTypes..
  ['grid-orientations'] = scene.nodeOrientations..
  ['spawn-nodes'] = getSceneSpawns(scene)..
  ['spawn-nodes-player'] = getScenePlayerSpawns(scene)..
  ['gameobjects'] = scene.gameObjects
    .where(isPersistable)
    .map(convertGameObjectToJson)
    .toList();

List<int> getSceneSpawns(Scene scene) {
  final volume = scene.gridVolume;
  final spawnPoints = <int>[];
  final nodeTypes = scene.nodeTypes;
  for (var i = 0; i < volume; i++) {
    if (nodeTypes[i] != NodeType.Spawn) continue;
    spawnPoints.add(i);
  }
  return spawnPoints;
}

List<int> getScenePlayerSpawns(Scene scene) {
  final volume = scene.gridVolume;
  final spawnPoints = <int>[];
  final nodeTypes = scene.nodeTypes;
  for (var i = 0; i < volume; i++) {
    if (nodeTypes[i] != NodeType.Spawn_Player) continue;
    spawnPoints.add(i);
  }
  return spawnPoints;
}

bool isPersistable(GameObject gameObject) =>
    ItemType.isPersistable(gameObject.type);