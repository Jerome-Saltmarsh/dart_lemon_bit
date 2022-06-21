
import 'package:typedef/json.dart';

import '../classes/enemy_spawn.dart';
import '../classes/grid_node.dart';
import '../classes/library.dart';
import 'convert_json_to_enemy_spawn.dart';

Scene convertJsonToScene(Json json) {
  final height = json.getInt('grid-z');
  final rows = json.getInt('grid-rows');
  final columns = json.getInt('grid-columns');
  var enemySpawns = <EnemySpawn>[];

  if (json.containsKey('enemy-spawns')){
     final enemySpawnsJson = json.getList('enemy-spawns');
     enemySpawns = enemySpawnsJson.map(convertJsonToEnemySpawn).toList();
  }

  return Scene(
    grid: convertFlatGridToGrid(json['grid'], height, rows, columns),
    gameObjects: [],
    characters: [],
    enemySpawns:enemySpawns,
  );
}


List<List<List<GridNode>>> convertFlatGridToGrid(List<dynamic> flatGrid, int height, int rows, int columns){
  final List<List<List<GridNode>>> grid = [];
  var index = 0;
  for (var zIndex = 0; zIndex < height; zIndex++){
    final plain = <List<GridNode>>[];
    grid.add(plain);
    for (var rowIndex = 0; rowIndex < rows; rowIndex++){
      final row = <GridNode>[];
      plain.add(row);
      for (var columnIndex = 0; columnIndex < columns; columnIndex++){
        row.add(GridNode(flatGrid[index]));
        index++;
      }
    }
  }
  return grid;
}
