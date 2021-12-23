
const explosionMaxDuration = 30;

enum EffectType {
  None,
  Explosion,
  FreezeCircle,
}

class Effect {
  double x = 0;
  double y = 0;
  int duration = 0;
  EffectType type = EffectType.None;
  bool enabled = false;
  int maxDuration = 0;
}