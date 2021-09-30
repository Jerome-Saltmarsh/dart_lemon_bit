import 'dart:convert';
import 'dart:io';

import '../classes/Block.dart';
import '../classes/Collectable.dart';
import '../classes/Scene.dart';
import '../common/Tile.dart';
import '../common/classes/Vector2.dart';
import '../common/CollectableType.dart';
import '../instances/scenes.dart';
import '../utils.dart';

final JsonDecoder _decoder = JsonDecoder();

void loadScenes() {
  print("loadScenes()");
  loadScene('fortress').then((value) => scenes.fortress = value);
  loadScene('town').then((value) => scenes.town = value);
}

Future<Scene> loadScene(String name) async {
  String dir = Directory.current.path;
  File fortressFile = File('$dir/scenes/$name.json');
  String text = await fortressFile.readAsString();
  return _mapStringToScene(text);
}

Scene _mapStringToScene(String text) {
  Map<String, dynamic> json = _decoder.convert(text);

  List collectablesInts = json['collectables'];
  List<Collectable> collectables = [];
  for (int i = 0; i < collectablesInts.length; i += 3) {
    CollectableType type = CollectableType.values[collectablesInts[i]];
    double x = collectablesInts[i + 1].toDouble();
    double y = collectablesInts[i + 2].toDouble();
    collectables.add(Collectable(x, y, type));
  }

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
      _row.add(Tile.values[compiledTiles[row][column]]);
    }
    tiles.add(_row);
  }

  List jsonBlocks = json['blocks'];
  List<Block> blocks = jsonBlocks.map(_mapJsonBlockToBlock).toList();
  sortBlocks(blocks);
  return Scene(tiles: tiles, blocks: blocks, crates: crates);
}

Block _mapJsonBlockToBlock(dynamic jsonBlock) {
  return Block(
    jsonBlock['tx'],
    jsonBlock['ty'],
    jsonBlock['rx'],
    jsonBlock['ry'],
    jsonBlock['bx'],
    jsonBlock['by'],
    jsonBlock['lx'],
    jsonBlock['ly'],
  );
}
