import 'package:lemon_math/library.dart';

const explosionMaxDuration = 30;

enum EffectType {
  None,
  Explosion,
  FreezeCircle,
}

class Effect extends Vector2 {
  double x = 0;
  double y = 0;
  int duration = 0;
  EffectType type = EffectType.None;
  bool enabled = false;
  int maxDuration = 0;

  Effect() : super(0, 0);

  double get percentage => duration / maxDuration;
}