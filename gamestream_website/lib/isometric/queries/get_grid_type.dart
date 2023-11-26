
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

Node gridGetType(int z, int row, int column){
  if (z < 0) return Node.boundary;
  if (row < 0) return Node.boundary;
  if (column < 0) return Node.boundary;
  if (z >= gridTotalZ) return Node.boundary;
  if (row >= gridTotalRows) return Node.boundary;
  if (column >= gridTotalColumns) return Node.boundary;
  return grid[z][row][column];
}