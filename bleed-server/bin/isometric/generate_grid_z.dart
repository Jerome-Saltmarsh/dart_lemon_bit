
import '../classes/grid_node.dart';
import '../common/grid_node_type.dart';

List<List<GridNode>> generateGridZ(int rows, int columns, {int type = GridNodeType.Empty}){
  final plain = <List<GridNode>>[];
  for (var rowIndex = 0; rowIndex < rows; rowIndex++){
    final row = <GridNode>[];
    plain.add(row);
    for (var columnIndex = 0; columnIndex < columns; columnIndex++){
      row.add(GridNode(type));
    }
  }
  return plain;
}