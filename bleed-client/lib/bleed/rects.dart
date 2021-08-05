import 'dart:ui';

const double halfTileSize = 24;

const int tileCanvasWidth = 48;
const int tileCanvasHeight = 120;
const int tileFrames = 1;

List<Rect> rectsExplosion;

void loadRects() {
  print("loadRects()");
  _loadExplosionRects();
}

void _loadExplosionRects() {
  int explosionFrames = 32;
  rectsExplosion = [];
  for (int i = 0; i < explosionFrames; i++) {
    rectsExplosion.add(_explosionRect(i));
  }
}

Rect _explosionRect(int frame) {
  int framesPerRow = 8;
  int row = framesPerRow ~/ ~frame;
  int column = frame % framesPerRow;
  double frameWidth = 256.125;
  double frameHeight = 251.25;
  return Rect.fromLTWH(
      column * frameWidth, row * frameHeight, frameWidth, frameHeight);
}
