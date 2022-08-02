
import 'package:typedef/json.dart';

import '../classes/enemy_spawn.dart';
import '../classes/library.dart';
import '../classes/node.dart';
import '../factories/generate_node.dart';

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

List<List<List<Node>>> convertFlatGridToGrid(List<dynamic> flatGrid, int height, int rows, int columns){
  final List<List<List<Node>>> grid = [];
  var index = 0;
  for (var zIndex = 0; zIndex < height; zIndex++){
    final plain = <List<Node>>[];
    grid.add(plain);
    for (var rowIndex = 0; rowIndex < rows; rowIndex++){
      final row = <Node>[];
      plain.add(row);
      for (var columnIndex = 0; columnIndex < columns; columnIndex++){
        row.add(generateNode(flatGrid[index]));
        index++;
      }
    }
  }
  return grid;
}
