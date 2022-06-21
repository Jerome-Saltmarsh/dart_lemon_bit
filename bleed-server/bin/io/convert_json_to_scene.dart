
import 'package:typedef/json.dart';

import '../classes/grid_node.dart';
import '../classes/library.dart';

Scene convertJsonToScene(Json json) {
  final height = json.getInt('grid-z');
  final rows = json.getInt('grid-rows');
  final columns = json.getInt('grid-columns');
  final flatGrid = json['grid'];

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
  return Scene(
    grid: grid,
    gameObjects: [],
    characters: [],
  );
}