import 'constants.dart';

double snapX(double x, double y) {
  final row = getRow(x, y);
  final column = getColumn(x, y);
  return getTileWorldX(row, column);
}

double snapY(double x, double y) {
  final row = getRow(x, y);
  final column = getColumn(x, y);
  return getTileWorldY(row, column) + tileSizeHalf;
}

double getTileWorldX(int row, int column){
  return perspectiveProjectX(row * tileSizeHalf, column * tileSizeHalf);
}

double getTileWorldY(int row, int column){
  return perspectiveProjectY(row * tileSizeHalf, column * tileSizeHalf);
}

double perspectiveProjectX(double x, double y) {
  return -y + x;
}

double perspectiveProjectY(double x, double y) {
  return x + y;
}

double projectedToWorldX(double x, double y) {
  return y - x;
}

double projectedToWorldY(double x, double y) {
  return x + y;
}

int getRow(double x, double y) {
  return (x + y) ~/ tileSize;
}

int getColumn(double x, double y) {
  return (y - x) ~/ tileSize;
}

