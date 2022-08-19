
import '../classes/node.dart';
import '../common/node_orientation.dart';
import '../common/node_type.dart';

List<List<List<Node>>> generate_grid_empty({
  required int zHeight,
  required int rows,
  required int columns,
}){
  assert(zHeight > 0);
  assert(rows > 0);
  assert(columns > 0);

  final grid = <List<List<Node>>>[];
  for (var z = 0; z < zHeight; z++) {
     final plain = <List<Node>>[];
     grid.add(plain);
     for (var row = 0; row < rows; row++){
         final r = <Node>[];
         plain.add(r);
         for (var column = 0; column < columns; column++){
            r.add(z == 0 ? NodeOriented(orientation: NodeOrientation.Solid, type: NodeType.Grass_2) : Node.empty);
         }
     }
  }
  return grid;
}