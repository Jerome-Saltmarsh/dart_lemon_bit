import 'package:bleed_common/SceneJson.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/constants.dart';
import 'package:gamestream_flutter/modules/isometric/classes.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:lemon_math/library.dart';
import 'package:typedef/json.dart';

import 'state.dart';

class EditorCompile {
  final EditorState state;
  EditorCompile(this.state);

  Json compileGameToJson() {
    return {
      "collectables": byteStreamParser.collectables,
      "tiles": compileTiles(isometric.tiles),
      // "environment": compileGameObjects(state.environmentObjects),
      'characters': compileCharactersToJson(state.characters),
      sceneFieldNames.startTime: modules.isometric.minutes.value * secondsPerHour,
      sceneFieldNames.secondsPerFrame: state.timeSpeed.value.index,
      sceneFieldNames.playerSpawnPoints: compileVector2ListToIntList(state.teamSpawnPoints),
      sceneFieldNames.items: compileItemsToJson(),
    };
  }

  List<List<String>> compileTiles(List<List<int>> tiles) {
    List<List<String>> _tiles = [];
    for (var row = 0; row < tiles.length; row++) {
      List<String> _row = [];
      for (int column = 0; column < tiles[0].length; column++) {
        _row.add(tileNames[tiles[row][column]]!);
      }
      _tiles.add(_row);
    }
    return _tiles;
  }

  List<int> compileItemsToJson(){
    final List<int> list = [];
    for(final item in state.items){
      list.add(item.type);
      list.add(item.x.toInt());
      list.add(item.y.toInt());
    }
    return list;
  }


  List<int> compileCrates(List<Vector2> crates) {
    List<int> values = [];
    for (Vector2 vector2 in crates) {
      if (vector2.isZero) return values;
      values.add(vector2.x.toInt());
      values.add(vector2.y.toInt());
    }
    return values;
  }

  // List<dynamic> compileGameObjects(List<GameObject> values) {
  //   return values
  //       .map((gameObject) => {
  //     'x': gameObject.x.toInt(),
  //     'y': gameObject.y.toInt(),
  //     'type': parseEnvironmentObjectTypeToString(gameObject.type)
  //   })
  //       .toList();
  // }



  List<int> compileVector2ListToIntList(List<Vector2> values){
    return values.fold<List<int>>([], (intList, vector2){
      intList.add(vector2.x.toInt());
      intList.add(vector2.y.toInt());
      return intList;
    });
  }

  List<dynamic> compileCharactersToJson(List<Character> characters){
    return characters.map(compileCharacterToJson).toList();
  }

  Json compileCharacterToJson(Character character){
    return {
      // 'type': enumString(character.type.name),
      'x': character.x.toInt(),
      'y': character.y.toInt(),
    };
  }
}