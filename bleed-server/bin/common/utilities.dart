const tileSize = 48.0;
const halfTileSize = 24.0;

double snapX(double x, double y) {
  final row = getRow(x, y);
  final column = getColumn(x, y);
  return getTileWorldX(row, column);
}

double snapY(double x, double y) {
  final row = getRow(x, y);
  final column = getColumn(x, y);
  return getTileWorldY(row, column) + halfTileSize;
}

double getTileWorldX(int row, int column){
  return perspectiveProjectX(row * halfTileSize, column * halfTileSize);
}

double getTileWorldY(int row, int column){
  return perspectiveProjectY(row * halfTileSize, column * halfTileSize);
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
