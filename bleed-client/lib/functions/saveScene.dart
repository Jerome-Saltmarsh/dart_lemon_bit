import 'dart:convert';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/instances/game.dart';
import 'package:bleed_client/state.dart';
import 'package:clipboard/clipboard.dart';

void saveScene() {
  print("saveScene()");
  FlutterClipboard.copy(_compileScene());
}

String _compileScene(){
  List jsonBlocks = blockHouses.map(mapBlockToJson).toList();
  return JsonEncoder().convert({
    "blocks": jsonBlocks,
    "collectables": game.collectables
  });
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
