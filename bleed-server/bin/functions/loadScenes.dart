import 'dart:convert';
import 'dart:io';

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
  loadScene('town').then((value) => scenes.town = value);
  loadScene('tavern').then((value) => scenes.tavern = value);
  loadScene('cave').then((value) => scenes.cave = value);
  loadScene('wilderness-west-01').then((value) => scenes.wildernessWest01 = value);
  loadScene('wilderness-north-01').then((value) => scenes.wildernessNorth01 = value);
  loadScene('wilderness-east').then((value) => scenes.wildernessEast = value);
  loadScene('royal').then((value) => scenes.royal = value);
}

Future<Scene> loadScene(String name) async {
  final String dir = Directory.current.path;
  final File fortressFile = File('$dir/scenes/$name.json');
  final String text = await fortressFile.readAsString();
  final Json sceneJson = jsonDecode(text);
  return parseJsonToScene(sceneJson);
}

Scene parseJsonToScene(Json json) {

  List<Vector2> playerSpawnPoints = [];
  if (json.containsKey('player-spawn-points')) {
    List playerSpawnPointsInts = json['player-spawn-points'];
    for (int i = 0; i < playerSpawnPointsInts.length; i += 2) {
      int x = playerSpawnPointsInts[i];
      int y = playerSpawnPointsInts[i + 1];
      playerSpawnPoints.add(Vector2(x.toDouble(), y.toDouble()));
    }
  }

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
  );

  if (json.containsKey(sceneFieldNames.startTime)){
     scene.startHour = json[sceneFieldNames.startTime];
  }
  if (json.containsKey(sceneFieldNames.secondsPerFrame)){
    scene.secondsPerFrames = json[sceneFieldNames.secondsPerFrame];
  }

  return scene;
}

