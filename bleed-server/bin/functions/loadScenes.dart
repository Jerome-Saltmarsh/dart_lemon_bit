
import 'dart:convert';
import 'dart:io';

import '../classes/Block.dart';
import '../classes/Collectable.dart';
import '../classes/Scene.dart';
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
  List<dynamic> jsonBlocks = json['blocks'];
  List<Block> blocks = jsonBlocks.map(_mapJsonBlockToBlock).toList();
  sortBlocks(blocks);
  List<Collectable> collectables = [];
  return Scene([], generateTiles(), blocks, collectables);
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