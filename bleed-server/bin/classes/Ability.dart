import '../common/AbilityType.dart';
import 'Character.dart';


class IronShield extends Ability {
  int durationRemaining = 0;
  int duration = 2;
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
            magicCost: 10,
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

class Ability {
  AbilityType type;
  int level;
  int magicCost;
  double range;
  int cooldownRemaining = 0;
  int cooldown;

  Ability({
    required this.type,
    required this.level,
    required this.magicCost,
    required this.range,
    required this.cooldown,
  });

  void update() {}
}
