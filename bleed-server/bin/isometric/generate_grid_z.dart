
import '../classes/node.dart';
import '../common/node_type.dart';
import 'generate_node.dart';

List<List<Node>> generateGridZ(
    int rows,
    int columns,
    {
      int type = NodeType.Empty
    }) =>
  List.generate(rows, (index) => generateGridRow(columns));

List<Node> generateGridRow(int columns, {int type = NodeType.Empty}) =>
  List.generate(columns, (index) => generateNode(type));