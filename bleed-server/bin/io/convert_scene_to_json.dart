
import 'dart:convert';

import 'package:typedef/json.dart';

import '../classes/Scene.dart';
import '../classes/grid_node.dart';
import 'convert_enemy_spawn_to_json.dart';

String convertSceneToString(Scene scene){
   final json = Json();
   json['grid-z'] = scene.gridHeight;
   json['grid-rows'] = scene.gridRows;
   json['grid-columns'] = scene.gridColumns;
   json['grid'] = flattenGrid(scene.grid);
   json['enemy-spawns'] = scene.enemySpawns.map(convertEnemySpawnToJson).toList();
   return jsonEncode(json);
}

List<int> flattenGrid(List<List<List<GridNode>>> grid) {
  final height = grid.length;
  final rows = grid[0].length;
  final columns = grid[0][0].length;
  final flattened = <int> [];
  for (var z = 0; z < height; z++){
    for (var row = 0; row < rows; row++){
      for (var column = 0; column < columns; column++){
        flattened.add(grid[z][row][column].type);
      }
    }
  }
  return flattened;
}