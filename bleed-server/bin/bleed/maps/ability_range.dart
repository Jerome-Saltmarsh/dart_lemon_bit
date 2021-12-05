
import '../../common/AbilityType.dart';

final _Maps _maps = _Maps();

class _Maps {
  Map<AbilityType, double> abilityRange = {
    AbilityType.None: 0,
    AbilityType.FreezeCircle: 200,
    AbilityType.Explosion: 200,
    AbilityType.Blink: 200,
  };
}

double getAbilityRange(AbilityType ability){
  double? r = _maps.abilityRange[ability];
  if (r != null) return r;
  return 0;
}