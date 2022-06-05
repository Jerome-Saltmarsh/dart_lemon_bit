import '../common/AbilityMode.dart';
import '../common/card_type.dart';
import 'Card.dart';

abstract class CardAbility extends Card {
  int cost;
  double range;
  int cooldownRemaining = 0;
  int cooldown;
  double radius;
  AbilityMode mode;

  bool get isModeArea => mode == AbilityMode.Area;

  CardAbility({
    required CardType type,
    required this.cost,
    required this.range,
    required this.cooldown,
    required this.mode,
    this.radius = 0,
  }) :super(type);

  void update() {}
}

class CardAbilityExplosion extends CardAbility {
  CardAbilityExplosion() : super(
      type: CardType.Ability_Explosion,
      cost: 1,
      range: 200,
      cooldown: 40,
      mode: AbilityMode.Area,
      radius: 75,
  );
}

class CardAbilityBowVolley extends CardAbility {
  CardAbilityBowVolley() : super(
      type: CardType.Ability_Bow_Volley,
      cost: 1,
      range: 200,
      cooldown: 30,
      mode: AbilityMode.Directed
  );
}

class CardAbilityBowLongShot extends CardAbility {
  CardAbilityBowLongShot() : super(
      type: CardType.Ability_Bow_Long_Shot,
      cost: 1,
      range: 400,
      cooldown: 20,
      mode: AbilityMode.Targeted,
  );
}

class CardAbilityFireball extends CardAbility {

  CardAbilityFireball() : super(
    type: CardType.Ability_Fireball,
    cost: 1,
    range: 200,
    cooldown: 10,
    mode: AbilityMode.Targeted,
  );
}


class CardPassive extends Card {
  CardPassive(CardType type) : super(type);
}

