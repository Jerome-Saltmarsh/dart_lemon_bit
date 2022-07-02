
import '../classes/grid_node.dart';
import '../common/grid_node_type.dart';

List<List<List<GridNode>>> generateEmptyGrid({
  required int zHeight,
  required int rows,
  required int columns,
}){
  final grid = <List<List<GridNode>>>[];
  for (var z = 0; z < zHeight; z++) {
     final plain = <List<GridNode>>[];
     grid.add(plain);
     for (var row = 0; row < rows; row++){
         final r = <GridNode>[];
         plain.add(r);
         for (var column = 0; column < columns; column++){
            r.add(GridNode(z == 0 ? GridNodeType.Grass : GridNodeType.Empty));
         }
     }
  }
  return grid;
}