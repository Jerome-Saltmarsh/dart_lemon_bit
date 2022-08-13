
import '../classes/node.dart';
import '../common/grid_node_type.dart';
import '../factories/generate_node.dart';

List<List<Node>> generateGridZ(
    int rows,
    int columns,
    {
      int type = GridNodeType.Empty
    }) =>
  List.generate(rows, (index) => generateGridRow(columns));

List<Node> generateGridRow(int columns, {int type = GridNodeType.Empty}) =>
  List.generate(columns, (index) => generateNode(type));