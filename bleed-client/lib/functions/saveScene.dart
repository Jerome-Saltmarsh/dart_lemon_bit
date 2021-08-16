import 'dart:convert';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/state.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';

void saveScene() {
  print("saveScene()");
  FlutterClipboard.copy(_compileScene());
}

String _compileScene(){
  return JsonEncoder().convert({
    "blocks": _mapBlocks(),
    "collectables": game.collectables,
    "player-spawn-points": _mapPlayerSpawnPoints(),
  });
}

List<dynamic> _mapBlocks() => blockHouses.map(mapBlockToJson).toList();

List<int> _mapPlayerSpawnPoints(){
  List<int> points = [];
  for(Offset offset in game.playerSpawnPoints){
    points.add(offset.dx.toInt());
    points.add(offset.dy.toInt());
  }
  return points;
}

dynamic mapBlockToJson(Block block){
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
