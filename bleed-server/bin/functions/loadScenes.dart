import 'dart:convert';
import 'dart:io';

import 'package:bleed_server/user-service-client/firestoreService.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:typedef/json.dart';

import '../classes/Character.dart';
import '../classes/Scene.dart';
import '../common/CharacterType.dart';
import '../common/SceneJson.dart';
import '../common/Tile.dart';
import '../classes/EnvironmentObject.dart';
import '../common/enums/ObjectType.dart';
import '../instances/scenes.dart';

void loadScenes() {
  print("loadScenes()");
  loadSceneFromFile('town').then((value) => scenes.town = value);
  loadSceneFromFile('tavern').then((value) => scenes.tavern = value);
  loadSceneFromFile('cave').then((value) => scenes.cave = value);
  loadSceneFromFile('wilderness-west-01').then((value) => scenes.wildernessWest01 = value);
  loadSceneFromFile('wilderness-north-01').then((value) => scenes.wildernessNorth01 = value);
  loadSceneFromFile('wilderness-east').then((value) => scenes.wildernessEast = value);
  loadSceneFromFireStore('royal').then((value) => scenes.royal = value);
}

Future<Scene> loadSceneFromFile(String name) async {
  final String dir = Directory.current.path;
  final File fortressFile = File('$dir/scenes/$name.json');
  final String text = await fortressFile.readAsString();
  final Json sceneJson = jsonDecode(text);
  return parseJsonToScene(sceneJson, name);
}

Future<Scene> loadSceneFromFireStore(String name) async {
  final Json sceneJson = await firestoreService.loadMap(name);
  return parseJsonToScene(sceneJson, name);
}

List<Vector2> compileIntListToVector2List(List values){
  if (values.length % 2 != 0){
    throw Exception("compileIntListToVector2List values.length cannot be odd");
  }
  final List<Vector2> vector2s = [];
  for (int i = 0; i < values.length; i += 2) {
    final x = (values[i]).toDouble();
    final y = (values[i + 1]).toDouble();
    vector2s.add(Vector2(x, y.toDouble()));
  }
  return vector2s;
}

Scene parseJsonToScene(Json json, String name) {

  final List<Vector2> zombieSpawnPoints = [];

  if (json.containsKey('zombie-spawn-points')) {
    final List zombieSpawnPointsInts = json['zombie-spawn-points'];
    for (int i = 0; i < zombieSpawnPointsInts.length; i += 2) {
      final int x = zombieSpawnPointsInts[i];
      final int y = zombieSpawnPointsInts[i + 1];
      zombieSpawnPoints.add(Vector2(x.toDouble(), y.toDouble()));
    }
  }

  final List<EnvironmentObject> environment = [];

  if (json.containsKey('environment')) {
    final List jsonItems = json['environment'];
    for (dynamic item in jsonItems) {
      final int x = item['x'];
      final int y = item['y'];
      final String typeName = item['type'];
      final ObjectType type = parseObjectTypeFromString(typeName);
      environment.add(EnvironmentObject(
        x: x.toDouble(),
        y: y.toDouble(),
        type: type
      ));
    }
  }

  List<Vector2> crates = [];

  if (json.containsKey('crates')){
    List cratesJson = json['crates'];
    for (int i = 0; i < cratesJson.length; i += 2) {
      int x = cratesJson[i];
      int y = cratesJson[i + 1];
      crates.add(Vector2(x.toDouble(), y.toDouble()));
    }
  }

  List compiledTiles = json['tiles'];
  List<List<Tile>> tiles = [];

  for(int row = 0; row < compiledTiles.length; row++){
    List<Tile> _row = [];
    for(int column = 0; column < compiledTiles[0].length; column++){
      String tileName = compiledTiles[row][column];
      Tile tile = parseStringToTile(tileName);
      _row.add(tile);
    }
    tiles.add(_row);
  }

  final List<Character> characters = [];

  if (json.containsKey('characters')){
    List characterJson = json['characters'];
    for (Json characterJson in characterJson) {
      final type = parseCharacterType(characterJson['type']);
      final x = (characterJson['x'] as int).toDouble();
      final y = (characterJson['y'] as int).toDouble();
      characters.add(Character(type: type, x: x, y: y, health: 100, speed: 1));
    }
  }

  final scene = Scene(
    tiles: tiles,
    crates: crates,
    environment: environment,
    characters: characters,
    name: name
  );

  if (json.containsKey(sceneFieldNames.startTime)){
     scene.startHour = json[sceneFieldNames.startTime];
  }
  if (json.containsKey(sceneFieldNames.secondsPerFrame)){
    scene.secondsPerFrames = json[sceneFieldNames.secondsPerFrame];
  }
  if (json.containsKey(sceneFieldNames.playerSpawnPoints)) {
    scene.playerSpawnPoints = compileIntListToVector2List(json[sceneFieldNames.playerSpawnPoints]);
  }

  return scene;
}

