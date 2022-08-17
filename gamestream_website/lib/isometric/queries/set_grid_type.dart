
import 'package:gamestream_flutter/isometric/factories/generate_grid_node.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void setGridType(int z, int row, int column, int type){
  if (z < 0)
    return;
  if (row < 0)
    return;
  if (column < 0)
    return;
  if (z >= gridTotalZ)
    return;
  if (row >= gridTotalRows)
    return;
  if (column >= gridTotalColumns)
    return;

  final current = grid[z][row][column];
  final next = generateNode(z, row, column, type);
  next.shade = current.shade;
  next.bake = current.bake;
  grid[z][row][column] = next;
}