
import '../../common/Ability.dart';

final _Maps _maps = _Maps();

class _Maps {
  Map<Ability, double> abilityRange = {
    Ability.None: 0,
    Ability.SlowingCircle: 200,
    Ability.Blink: 200,
  };
}

double getAbilityRange(Ability ability){
  double? r = _maps.abilityRange[ability];
  if (r != null) return r;
  return 0;
}