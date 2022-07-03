
import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

int gridGetType(int z, int row, int column){
  if (z < 0) return GridNodeType.Boundary;
  if (row < 0) return GridNodeType.Boundary;
  if (column < 0) return GridNodeType.Boundary;
  if (z >= gridTotalZ) return GridNodeType.Boundary;
  if (row >= gridTotalRows) return GridNodeType.Boundary;
  if (column >= gridTotalColumns) return GridNodeType.Boundary;
  return grid[z][row][column];
}