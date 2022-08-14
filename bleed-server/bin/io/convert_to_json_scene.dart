
import 'dart:convert';

import 'package:typedef/json.dart';

import '../classes/node.dart';
import '../classes/scene.dart';
import '../common/library.dart';
import 'convert_enemy_spawn_to_json.dart';
import 'to_json_gameobject.dart';



String convertSceneToString(Scene scene){
   final json = Json();
   json['grid-z'] = scene.gridHeight;
   json['grid-rows'] = scene.gridRows;
   json['grid-columns'] = scene.gridColumns;
   json['grid'] = flattenGrid(scene.grid);
   json['enemy-spawns'] = scene.enemySpawns.map(toJsonEnemySpawn).toList();
   json['gameobjects'] = scene.gameObjects.map(toJsonGameObject).toList();
   return jsonEncode(json);
}

List<int> flattenGrid(List<List<List<Node>>> grid) {
  final height = grid.length;
  final rows = grid[0].length;
  final columns = grid[0][0].length;
  final flattened = List.filled(height * rows * columns, GridNodeType.Empty);
  var i = 0;
  for (final z in grid) {
    for(final row in z) {
      for (final column in row) {
        flattened[i] = column.type;
        i++;
      }
    }
  }
  return flattened;
}