
import '../classes/library.dart';
import '../isometric/generate_empty_grid.dart';

Scene generateEmptyScene(){
  return Scene(
    name: '',
    gameObjects: [],
    grid: generate_grid_empty(
      zHeight: 8,
      rows: 50,
      columns: 50,
    ),
  );
}