
import '../common/grid_node_type.dart';

List<List<List<int>>> generateEmptyGrid({
  required int zHeight,
  required int rows,
  required int columns,
}){
  assert(zHeight > 0);
  assert(rows > 0);
  assert(columns > 0);

  final grid = <List<List<int>>>[];
  for (var z = 0; z < zHeight; z++) {
     final plain = <List<int>>[];
     grid.add(plain);
     for (var row = 0; row < rows; row++){
         final r = <int>[];
         plain.add(r);
         for (var column = 0; column < columns; column++){
            r.add(z == 0 ? GridNodeType.Grass : GridNodeType.Empty);
         }
     }
  }
  return grid;
}