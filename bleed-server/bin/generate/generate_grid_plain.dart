import '../common/grid_node_type.dart';

List<List<List<int>>> generateGridPlain({int rows = 50, int columns = 50, int height = 7}) {
  final List<List<List<int>>> grid = [];
  for (var z = 0; z < height; z++) {
    final layer = <List<int>>[];
    grid.add(layer);
    for (var rowIndex = 0; rowIndex < rows; rowIndex++) {
      final row = <int>[];
      layer.add(row);
      for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
        row.add(z == 0 ? GridNodeType.Grass : GridNodeType.Empty);
      }
    }
  }
  return grid;
}