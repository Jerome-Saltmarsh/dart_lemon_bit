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
  AbilityBowVolley() : super(
      level: 1,
      cost: 1,
      range: 200,
      cooldown: 100,
      mode: AbilityMode.Directed
  );
}

class AbilityBowLongShot extends Ability {
  AbilityBowLongShot() : super(
      level: 1,
      cost: 1,
      range: 400,
      cooldown: 100,
      mode: AbilityMode.Targeted,
  );
}



