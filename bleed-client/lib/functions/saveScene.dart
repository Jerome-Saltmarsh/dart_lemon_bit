import 'dart:convert';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/environmentObjects.dart';
import 'package:bleed_client/state.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';

void saveScene() {
  print("saveScene()");
  FlutterClipboard.copy(_mapCompileGameToJson());
}

String toJson(Object object) {
  return JsonEncoder().convert(object);
}

String _mapCompileGameToJson() {
  return toJson(_mapCompiledGameToObject());
}

Object _mapCompiledGameToObject() {

  List<EnvironmentObject> all = [
    ...environmentObjects,
    ...game.backgroundObjects
  ];

  return {
    "blocks": _compileBlocks(),
    "collectables": game.collectables,
    "tiles": _compileTiles(game.tiles),
    "crates": _compileCrates(game.crates),
    "environment": _compileEnvironmentObjects(all),
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

List<dynamic> _compileEnvironmentObjects(List<EnvironmentObject> values) {
  return values
      .map((environmentObject) => {
            'x': environmentObject.x.toInt(),
            'y': environmentObject.y.toInt(),
            'type': parseEnvironmentObjectTypeToString(environmentObject.type)
          })
      .toList();
}

List<List<String>> _compileTiles(List<List<Tile>> tiles) {
  List<List<String>> _tiles = [];
  for (int row = 0; row < tiles.length; row++) {
    List<String> _row = [];
    for (int column = 0; column < tiles[0].length; column++) {
      _row.add(parseTileToString(tiles[row][column]));
    }
    _tiles.add(_row);
  }
  return _tiles;
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
