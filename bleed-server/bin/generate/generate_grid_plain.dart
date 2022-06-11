import '../classes/Scene.dart';
import '../common/grid_node_type.dart';

List<List<List<GridNode>>> generateGridPlain({int rows = 50, int columns = 50, int height = 7}) {
  final List<List<List<GridNode>>> grid = [];
  for (var z = 0; z < height; z++) {
    final layer = <List<GridNode>>[];
    grid.add(layer);
    for (var rowIndex = 0; rowIndex < rows; rowIndex++) {
      final row = <GridNode>[];
      layer.add(row);
      for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
        row.add(GridNode(z == 0 ? GridNodeType.Grass : GridNodeType.Empty));
      }
    }
  }
  return grid;
}