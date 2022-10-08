
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';

void setGridType(int z, int row, int column, int type){
  if (z < 0)
    return;
  if (row < 0)
    return;
  if (column < 0)
    return;
  if (z >= nodesTotalZ)
    return;
  if (row >= nodesTotalRows)
    return;
  if (column >= nodesTotalColumns)
    return;

  nodesType[getNodeIndexZRC(z, row, column)] = type;
}