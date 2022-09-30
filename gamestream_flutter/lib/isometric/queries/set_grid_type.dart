
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid_state.dart';

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

  gridNodeTypes[gridNodeIndexZRC(z, row, column)] = type;
}