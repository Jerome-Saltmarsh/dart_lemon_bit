
import '../classes/library.dart';
import '../isometric/generate_empty_grid.dart';

Scene generateEmptyScene(){
  return Scene(
    name: '',
    characters: [],
    enemySpawns: [],
    grid: generate_grid_empty(
      zHeight: 8,
      rows: 50,
      columns: 50,
    ),
  );
}