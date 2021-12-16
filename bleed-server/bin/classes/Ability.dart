import '../common/AbilityMode.dart';
import '../common/AbilityType.dart';
import 'Character.dart';


class IronShield extends Ability {
  int durationRemaining = 0;
  int duration = 4;
  Character character;

  IronShield(this.character)
      : super(
      type: AbilityType.Iron_Shield,
      level: 0,
      magicCost: 10,
      range: 0,
      cooldown: 15);

  void update() {
    if (durationRemaining > 0){
      durationRemaining--;
      if (durationRemaining <= 0){
        character.invincible = false;
      }
    }
  }
}

const double dashSpeed = 1.25;

class Dash extends Ability {
  int durationRemaining = 0;
  int duration = 2;
  Character character;

  Dash(this.character)
      : super(
            type: AbilityType.Dash,
            level: 0,
            magicCost: 30,
            range: 0,
            cooldown: 15);

  void update() {
    if (durationRemaining > 0){
      durationRemaining--;
      if (durationRemaining <= 0){
        character.speedModifier -= dashSpeed;
      }
    }
  }
}

final Map<AbilityType, AbilityMode> _mapAbilityTypeToAbilityMode = {
  AbilityType.FreezeCircle: AbilityMode.Area,
  AbilityType.Blink: AbilityMode.Directed,
  AbilityType.Explosion: AbilityMode.Area,
  AbilityType.Dash: AbilityMode.Directed,
  AbilityType.Fireball: AbilityMode.Targeted,
  AbilityType.Split_Arrow: AbilityMode.Directed,
  AbilityType.Long_Shot: AbilityMode.Targeted,
  AbilityType.Iron_Shield: AbilityMode.Activated,
  AbilityType.Brutal_Strike: AbilityMode.Directed,
  AbilityType.Death_Strike: AbilityMode.Targeted,
};

class Ability {
  AbilityType type;
  int level;
  int magicCost;
  double range;
  int cooldownRemaining = 0;
  int cooldown;
  double radius;

  AbilityMode get mode {
    AbilityMode? mode = _mapAbilityTypeToAbilityMode[type];
    if (mode != null) return mode;
    return AbilityMode.None;
  }

  Ability({
    required this.type,
    required this.level,
    required this.magicCost,
    required this.range,
    required this.cooldown,
    this.radius = 0,
  });

  void update() {}
}
