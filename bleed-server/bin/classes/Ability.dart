import '../common/AbilityType.dart';
import '../utils.dart';

class Ability {
  AbilityType type;
  int level;
  int magicCost;
  int range;
  int cooldownRemaining = 0;
  int cooldown;

  Ability({
      required this.type,
      required this.level,
      required this.magicCost,
      required this.range,
      required this.cooldown
  });
}
