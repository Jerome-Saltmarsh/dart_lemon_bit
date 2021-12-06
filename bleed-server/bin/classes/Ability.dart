
import '../common/AbilityType.dart';

class Ability {
  AbilityType type;
  int level;
  int magicCost;
  int range;

  Ability({required this.type, required this.level, required this.magicCost, required this.range});
}

final Ability abilityNone = Ability(type: AbilityType.None, level: 0, magicCost: 0, range: 0);