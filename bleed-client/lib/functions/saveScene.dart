import 'dart:convert';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/state.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';

void saveScene() {
  print("saveScene()");
  try {
    FlutterClipboard.copy(_compileScene());
  }catch(e){
    print(_compileScene());
  }
}

String _compileScene() {
  return JsonEncoder().convert({
    "blocks": _compileBlocks(),
    "collectables": compiledGame.collectables,
    "player-spawn-points": _compilePlayerSpawnPoints(),
    "zombie-spawn-points": _compileZombieSpawnPoints(),
    "tiles": _compileTiles(compiledGame.tiles)
  });
}

List<dynamic> _compileBlocks() => blockHouses.map(mapBlockToJson).toList();

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
