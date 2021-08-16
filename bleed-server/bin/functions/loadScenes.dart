import 'dart:convert';
import 'dart:io';

import '../classes/Block.dart';
import '../classes/Collectable.dart';
import '../classes/Scene.dart';
import '../classes/Vector2.dart';
import '../enums/CollectableType.dart';
import '../instances/scenes.dart';
import '../utils.dart';

final JsonDecoder _decoder = JsonDecoder();

void loadScenes() {
  print("loadScenes()");
  String dir = Directory.current.path;
  File file = File('$dir/scenes/town.json');
  file.readAsString().then((value) {
    scenesTown = _mapStringToScene(value);
  });
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

  List jsonBlocks = json['blocks'];
  List<Block> blocks = jsonBlocks.map(_mapJsonBlockToBlock).toList();
  sortBlocks(blocks);
  return Scene(generateTiles(), blocks, collectables, playerSpawnPoints, []);
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
