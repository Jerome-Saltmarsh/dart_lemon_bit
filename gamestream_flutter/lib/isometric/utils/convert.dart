
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_math/library.dart';

double convertWorldToGridX(double x, double y) {
  return x + y;
}

double convertWorldToGridY(double x, double y) {
  return y - x;
}

int convertWorldToRow(double x, double y, double z) {
  return (x + y + z) ~/ tileSize;
}

int convertWorldToColumn(double x, double y, double z) {
  return (y - x + z) ~/ tileSize;
}

int convertWorldToRowSafe(double x, double y, double z) {
  return clamp(convertWorldToRow(x, y, z), 0, gridTotalRows - 1);
}

int convertWorldToColumnSafe(double x, double y, double z) {
  return clamp(convertWorldToColumn(x, y, z), 0, gridTotalColumns - 1);
}

double convertRowColumnToX(int row, int column){
  return (row - column) * tileSizeHalf;
}

double convertRowColumnToY(int row, int column){
  return (row + column) * tileSizeHalf;
  // return ((row + column) * tileSizeHalf) - (z * tileHeight);
}

double convertRowColumnZToY(int row, int column, int z){
  return ((row + column) * tileSizeHalf) - (z * tileHeight);
}

