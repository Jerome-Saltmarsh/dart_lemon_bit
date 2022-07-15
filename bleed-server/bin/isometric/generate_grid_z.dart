
import '../common/grid_node_type.dart';

List<List<int>> generateGridZ(int rows, int columns, {int type = GridNodeType.Empty}){
  final plain = <List<int>>[];
  for (var rowIndex = 0; rowIndex < rows; rowIndex++){
    final row = <int>[];
    plain.add(row);
    for (var columnIndex = 0; columnIndex < columns; columnIndex++){
      row.add(type);
    }
  }
  return plain;
}