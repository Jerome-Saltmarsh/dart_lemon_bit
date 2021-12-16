
const explosionMaxDuration = 30;

enum EffectType {
  Explosion,
  FreezeCircle,
}

class Effect {
  double x;
  double y;
  int duration = 0;
  int maxDuration;
  EffectType type;
  bool enabled = true;

  Effect({this.x, this.y, this.type, int duration}){
    maxDuration = duration;
  }
}