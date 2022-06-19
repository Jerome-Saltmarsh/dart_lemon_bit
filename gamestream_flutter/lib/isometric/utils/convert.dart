
import 'package:bleed_common/tile_size.dart';

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