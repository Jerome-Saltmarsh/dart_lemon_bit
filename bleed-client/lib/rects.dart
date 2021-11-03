import 'dart:ui';

const int tileSize = 48;
const double halfTileSize = 24;
const int tileCanvasWidth = 48;
const int tileCanvasHeight = 48;
const int tileCanvasWidthHalf = tileCanvasWidth ~/ 2;
const int tileCanvasHeightHalf = tileCanvasHeight ~/ 2;

List<Rect> rectsExplosion;
List<Rect> rectsCharacter;
Rect rectParticleSmoke = rect(0, 64, 64);
Rect rectParticleBlood = rect(1, 64, 64);
Rect rectParticleHead = rect(2, 64, 64);
Rect rectParticleArm = rect(3, 64, 64);
Rect rectParticleOrgan = rect(4, 64, 64);
Rect rectParticleShell = rect(5, 64, 64);

Rect rectCrate = rect(1, 48, 72);


Rect rect(int index, double width, double height){
  return Rect.fromLTWH(width * (index - 1), 0, width, height);
}



