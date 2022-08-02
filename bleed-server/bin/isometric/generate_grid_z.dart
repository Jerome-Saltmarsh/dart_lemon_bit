
import '../classes/node.dart';
import '../common/grid_node_type.dart';
import '../factories/generate_node.dart';

List<List<Node>> generateGridZ(int rows, int columns, {int type = GridNodeType.Empty}){
  final plain = <List<Node>>[];
  for (var rowIndex = 0; rowIndex < rows; rowIndex++){
    final row = <Node>[];
    plain.add(row);
    for (var columnIndex = 0; columnIndex < columns; columnIndex++){
      row.add(generateNode(type));
    }
  }
  return plain;
}