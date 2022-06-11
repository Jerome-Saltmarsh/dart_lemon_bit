
import 'package:lemon_math/functions/vector2.dart';
import 'package:typedef/json.dart';

import '../classes/library.dart';
import '../scene/generate_tiles_plain.dart';

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
    tiles: generateTilesPlain(50, 50),
    structures: [],
    gameObjects: [],
    characters: [],
    spawnPointPlayers: [Vector2(0, 100)],
    spawnPointZombies: [Vector2(0, 200)],
  );
}