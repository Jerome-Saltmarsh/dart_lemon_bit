import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';

int getNodeShade(int z, int row, int column){
  if (outOfBounds(z, row, column)) ambientShade.value;
  return grid[z][row][column].shade;
}