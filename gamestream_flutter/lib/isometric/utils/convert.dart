
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_math/library.dart';

double convertGridToWorldX(double x, double y) {
  return x - y;
}

double convertGridToWorldY(double x, double y) {
  return x + y;
}

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

