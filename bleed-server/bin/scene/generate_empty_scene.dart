
import '../classes/library.dart';
import '../isometric/generate_empty_grid.dart';

Scene generateEmptyScene(){
  return Scene(
    name: '',
    gameObjects: [],
    characters: [],
    enemySpawns: [],
    grid: generateEmptyGrid(
      zHeight: 8,
      rows: 50,
      columns: 50,
    ),
  );
}