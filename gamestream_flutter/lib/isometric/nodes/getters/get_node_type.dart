
import 'package:bleed_common/node_type.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

int getNodeType(int z, int row, int column){
  if (outOfBounds(z, row, column)) return NodeType.Boundary;
  return grid[z][row][column].type;
}
