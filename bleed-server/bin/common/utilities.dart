const tileSize = 48.0;
const halfTileSize = 24.0;

double snapX(double x) {
  return  (x - x % tileSize) + halfTileSize;
}

double snapY(double y) {
  return y - y % tileSize;
}

