import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/SceneJson.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/constants.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/modules/editor/state.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/toString.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:typedef/json.dart';

class EditorCompile {
  final EditorState state;
  EditorCompile(this.state);

  Json compileGameToJson() {
    return {
      "collectables": game.collectables,
      "tiles": compileTiles(isometric.state.tiles),
      "crates": compileCrates(game.crates),
      "environment": compileEnvironmentObjects(state.environmentObjects),
      'characters': compileCharactersToJson(state.characters),
      sceneFieldNames.startTime: modules.isometric.state.minutes.value * secondsPerHour,
      sceneFieldNames.secondsPerFrame: state.timeSpeed.value.index,
      sceneFieldNames.playerSpawnPoints: compileVector2ListToIntList(state.teamSpawnPoints),
      sceneFieldNames.items: compileItemsToJson(),
    };
  }

  List<List<String>> compileTiles(List<List<Tile>> tiles) {
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

  List<int> compileItemsToJson(){
    final List<int> list = [];
    for(final item in state.items){
      list.add(item.type.index);
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

  List<dynamic> compileEnvironmentObjects(List<EnvironmentObject> values) {
    return values
        .map((environmentObject) => {
      'x': environmentObject.x.toInt(),
      'y': environmentObject.y.toInt(),
      'type': parseEnvironmentObjectTypeToString(environmentObject.type)
    })
        .toList();
  }



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
      'type': enumString(character.type.name),
      'x': character.x.toInt(),
      'y': character.y.toInt(),
    };
  }
}