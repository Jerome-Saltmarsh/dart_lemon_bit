
import '../classes/library.dart';
import '../isometric/generate_empty_grid.dart';

Scene generateEmptyScene(){
  return Scene(
    name: '',
    characters: [],
    enemySpawns: [],
    grid: generateEmptyGrid(
      zHeight: 8,
      rows: 50,
      columns: 50,
    ),
  );
}