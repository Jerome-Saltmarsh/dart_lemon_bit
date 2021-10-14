import 'dart:convert';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/state.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';

void saveScene() {
  print("saveScene()");
  try {
    FlutterClipboard.copy(_mapCompileGameToJson());
  } catch (e) {
    print(_mapCompileGameToJson());
  }
}

String toJson(Object object) {
  return JsonEncoder().convert(object);
}

String _mapCompileGameToJson() {
  return toJson(_mapCompiledGameToObject());
}

Object _mapCompiledGameToObject() {
  return {
    "blocks": _compileBlocks(),
    "collectables": compiledGame.collectables,
    "player-spawn-points": _compilePlayerSpawnPoints(),
    "zombie-spawn-points": _compileZombieSpawnPoints(),
    "tiles": _compileTiles(compiledGame.tiles),
    "crates": _compileCrates(compiledGame.crates),
    "environment": _compileEnvironmentObjects(compiledGame.environmentObjects),
  };
}

List<dynamic> _compileBlocks() => blockHouses.map(mapBlockToJson).toList();

List<int> _compileCrates(List<Vector2> crates) {
  List<int> values = [];
  for (Vector2 vector2 in crates) {
    if (vector2.isZero) return values;
    values.add(vector2.x.toInt());
    values.add(vector2.y.toInt());
  }
  return values;
}

List<dynamic> _compileEnvironmentObjects(List<EnvironmentObject> values){
  return values.map((environmentObject) => {
    'x': environmentObject.x.toInt(),
    'y': environmentObject.y.toInt(),
    'type': environmentObject.type.index
  }).toList();
}

List<List<int>> _compileTiles(List<List<Tile>> tiles) {
  List<List<int>> _tiles = [];
  for (int row = 0; row < tiles.length; row++) {
    List<int> _row = [];
    for (int column = 0; column < tiles[0].length; column++) {
      _row.add(tiles[row][column].index);
    }
    _tiles.add(_row);
  }
  return _tiles;
}

List<int> _compilePlayerSpawnPoints() {
  return _compileOffsets(compiledGame.playerSpawnPoints);
}

List<int> _compileZombieSpawnPoints() {
  return _compileOffsets(compiledGame.zombieSpawnPoints);
}

List<int> _compileOffsets(List<Offset> offsets) {
  List<int> points = [];
  for (Offset offset in offsets) {
    points.add(offset.dx.toInt());
    points.add(offset.dy.toInt());
  }
  return points;
}

dynamic mapBlockToJson(Block block) {
  return {
    "tx": block.top.dx.toInt(),
    "ty": block.top.dy.toInt(),
    "rx": block.right.dx.toInt(),
    "ry": block.right.dy.toInt(),
    "bx": block.bottom.dx.toInt(),
    "by": block.bottom.dy.toInt(),
    "lx": block.left.dx.toInt(),
    "ly": block.left.dy.toInt(),
  };
}
