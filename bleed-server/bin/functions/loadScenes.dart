import 'dart:convert';
import 'dart:io';

import 'package:lemon_math/Vector2.dart';
import 'package:typedef/json.dart';

import '../classes/Scene.dart';
import '../common/Tile.dart';
import '../classes/EnvironmentObject.dart';
import '../common/enums/ObjectType.dart';
import '../instances/scenes.dart';

final JsonDecoder _decoder = JsonDecoder();

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
  return mapJsonToScene(sceneJson);
}

Scene mapJsonToScene(Json json) {

  List<Vector2> playerSpawnPoints = [];
  if (json.containsKey('player-spawn-points')) {
    List playerSpawnPointsInts = json['player-spawn-points'];
    for (int i = 0; i < playerSpawnPointsInts.length; i += 2) {
      int x = playerSpawnPointsInts[i];
      int y = playerSpawnPointsInts[i + 1];
      playerSpawnPoints.add(Vector2(x.toDouble(), y.toDouble()));
    }
  }

  List<Vector2> zombieSpawnPoints = [];

  if (json.containsKey('zombie-spawn-points')) {
    List zombieSpawnPointsInts = json['zombie-spawn-points'];
    for (int i = 0; i < zombieSpawnPointsInts.length; i += 2) {
      int x = zombieSpawnPointsInts[i];
      int y = zombieSpawnPointsInts[i + 1];
      zombieSpawnPoints.add(Vector2(x.toDouble(), y.toDouble()));
    }
  }

  List<EnvironmentObject> environment = [];

  if (json.containsKey('environment')) {
    List jsonItems = json['environment'];
    for (dynamic item in jsonItems) {
      int x = item['x'];
      int y = item['y'];
      String typeName = item['type'];
      ObjectType type = parseObjectTypeFromString(typeName);
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

  return Scene(
      tiles: tiles,
      crates: crates,
      environment: environment
  );
}

