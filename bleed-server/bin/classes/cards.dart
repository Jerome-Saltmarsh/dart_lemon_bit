import '../common/AbilityMode.dart';
import '../common/card_type.dart';
import 'Card.dart';

abstract class CardAbility extends Card {
  int level;
  int cost;
  double range;
  int cooldownRemaining = 0;
  int cooldown;
  double radius;
  AbilityMode mode;

  CardAbility({
    required CardType type,
    required this.level,
    required this.cost,
    required this.range,
    required this.cooldown,
    required this.mode,
    this.radius = 0,
  }) :super(type);

  void update() {}
}

class CardAbilityBowVolley extends CardAbility {
  CardAbilityBowVolley() : super(
      type: CardType.Ability_Bow_Volley,
      level: 1,
      cost: 1,
      range: 200,
      cooldown: 30,
      mode: AbilityMode.Directed
  );
}

class CardAbilityBowLongShot extends CardAbility {
  CardAbilityBowLongShot() : super(
      type: CardType.Ability_Bow_Long_Shot,
      level: 1,
      cost: 1,
      range: 400,
      cooldown: 20,
      mode: AbilityMode.Targeted,
  );
}


class CardPassive extends Card {
  CardPassive(CardType type) : super(type);
}

