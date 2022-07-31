
import 'package:typedef/json.dart';

import '../classes/enemy_spawn.dart';
import '../classes/library.dart';

Scene convertJsonToScene(Json json, String name) {
  final height = json.getInt('grid-z');
  final rows = json.getInt('grid-rows');
  final columns = json.getInt('grid-columns');
  var enemySpawns = <EnemySpawn>[];

  return Scene(
    name: name,
    grid: convertFlatGridToGrid(json['grid'], height, rows, columns),
    characters: [],
    enemySpawns:enemySpawns,
  );
}

List<List<List<int>>> convertFlatGridToGrid(List<dynamic> flatGrid, int height, int rows, int columns){
  final List<List<List<int>>> grid = [];
  var index = 0;
  for (var zIndex = 0; zIndex < height; zIndex++){
    final plain = <List<int>>[];
    grid.add(plain);
    for (var rowIndex = 0; rowIndex < rows; rowIndex++){
      final row = <int>[];
      plain.add(row);
      for (var columnIndex = 0; columnIndex < columns; columnIndex++){
        row.add(flatGrid[index]);
        index++;
      }
    }
  }
  return grid;
}
