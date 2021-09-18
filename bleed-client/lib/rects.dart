import 'dart:ui';

const int tileSize = 48;
const double halfTileSize = 24;
const int tileCanvasWidth = 48;
const int tileCanvasHeight = 72;
const int tileCanvasWidthHalf = tileCanvasWidth ~/ 2;
const int tileCanvasHeightHalf = tileCanvasHeight ~/ 2;
const int tileFrames = 1;

Rect rectGunShotFlash = Rect.fromLTWH(0, 0, 16, 16);

Rect concreteRect = rect(0, 48, 48);
Rect grassRect = rect(1, 48, 48);

List<Rect> rectsExplosion;
List<Rect> rectsCharacter;
Rect rectParticleSmoke = rect(0, 64, 64);
Rect rectParticleBlood = rect(1, 64, 64);
Rect rectParticleHead = rect(2, 64, 64);
Rect rectParticleArm = rect(3, 64, 64);
Rect rectParticleOrgan = rect(4, 64, 64);
Rect rectParticleShell = rect(5, 64, 64);


Rect rect(int index, double width, double height){
  return Rect.fromLTWH(width * index, 0, width, height);
}

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
