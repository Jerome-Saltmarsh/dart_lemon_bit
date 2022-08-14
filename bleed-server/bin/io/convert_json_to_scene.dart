
import 'package:typedef/json.dart';

import '../classes/enemy_spawn.dart';
import '../classes/library.dart';
import '../classes/node.dart';
import '../isometric/generate_node.dart';

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
  var index = 0;
  final List<List<List<Node>>> grid = List.generate(height, (zIndex) {
    return List.generate(rows, (rowIndex){
      return List.generate(columns, (columnIndex){
        final node = generateNode(flatGrid[index]);
        index++;
        return node;
      });
    });
  });
  return grid;
}
