import '../common/AbilityMode.dart';

abstract class Ability {
  int level;
  int cost;
  double range;
  int cooldownRemaining = 0;
  int cooldown;
  double radius;
  AbilityMode mode;

  Ability({
    required this.level,
    required this.cost,
    required this.range,
    required this.cooldown,
    required this.mode,
    this.radius = 0,
  });

  void update() {}
}

class AbilityBowVolley extends Ability {
  AbilityBowVolley({
    required int level,
    required int cost,
    required double range,
    required int cooldown
  })
      : super(level: level, cost: cost, range: range, cooldown: cooldown, mode: AbilityMode.Directed);
}



