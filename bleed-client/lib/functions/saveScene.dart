import 'dart:convert';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:clipboard/clipboard.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:typedef/json.dart';

void copyCompiledGameToClipboard() {
  FlutterClipboard.copy(mapCompileGameToJson());
}

String mapCompileGameToJson() {
  return jsonEncode(compileGameToJson());
}

Json compileGameToJson() {
  return {
    "collectables": game.collectables,
    "tiles": _compileTiles(game.tiles),
    "crates": _compileCrates(game.crates),
    "environment": _compileEnvironmentObjects(game.environmentObjects),
    'characters': compileCharactersToJson(editor.state.characters),
    "misc" : _compileMisc(),
  };
}

Json _compileMisc(){
  return {
    'start-hour': editor.state.startingHour.value
  };
}

List<dynamic> compileCharactersToJson(List<Character> characters){
  return characters.map(compileCharacterToJson).toList();
}

Json compileCharacterToJson(Character character){
  return {
    'type': enumString(character.type.name),
    'x': character.x.toInt(),
    'y': character.y.toInt(),
  };
}


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

