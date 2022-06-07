import 'constants.dart';

double snapX(double x, double y) {
  return getTileWorldX(convertWorldToRow(x, y), convertWorldToColumn(x, y));
}

double snapY(double x, double y) {
  final row = convertWorldToRow(x, y);
  final column = convertWorldToColumn(x, y);
  return getTileWorldY(row, column) + tileSizeHalf;
}

double getTileWorldX(int row, int column){
  return convertGridToWorldX(row * tileSizeHalf, column * tileSizeHalf);
}

double getTileWorldY(int row, int column){
  return convertGridToWorldY(row * tileSizeHalf, column * tileSizeHalf);
}

double convertGridToWorldX(double x, double y) {
  return x - y;
}

double convertGridToWorldY(double x, double y) {
  return x + y;
}

double convertWorldToGridX(double x, double y) {
  return y - x;
}

double convertWorldToGridY(double x, double y) {
  return x + y;
}

int convertWorldToRow(double x, double y) {
  return (x + y) ~/ tileSize;
}

int convertWorldToColumn(double x, double y) {
  return (y - x) ~/ tileSize;
}
