
const explosionMaxDuration = 30;

enum ExplosionType {
  Explosion,
  FreezeCircle,
}

class Explosion {
  double x;
  double y;
  int duration = 0;
  ExplosionType type;

  Explosion({this.x, this.y, this.type});
}