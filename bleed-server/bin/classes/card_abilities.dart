import '../common/AbilityMode.dart';
import '../common/card_type.dart';
import 'Card.dart';

abstract class CardAbility extends Card {
  int cooldownRemaining = 0;
  int cooldown;
  AbilityMode mode;

  double get range;
  int get damage;
  double get radius => 0;

  bool get isModeArea => mode == AbilityMode.Area;

  CardAbility({
    required CardType type,
    required this.cooldown,
    required this.mode,
  }) :super(type);

  void update() {}
}


class CardAbilityExplosion extends CardAbility {

  @override
  double get range => 200;

  @override
  double get radius => 40;

  @override
  int get damage => 5 * level;

  CardAbilityExplosion() : super(
      type: CardType.Ability_Explosion,
      cooldown: 40,
      mode: AbilityMode.Area,
  );
}

class CardAbilityBowVolley extends CardAbility {

  @override
  int get damage => 3;

  @override
  double get range => 200;

  CardAbilityBowVolley() : super(
      type: CardType.Ability_Bow_Volley,
      cooldown: 30,
      mode: AbilityMode.Directed
  );
}

class CardAbilityBowLongShot extends CardAbility {

  @override
  double get range => 300;

  @override
  int get damage => 10 + (level * 5);

  CardAbilityBowLongShot() : super(
      type: CardType.Ability_Bow_Long_Shot,
      cooldown: 20,
      mode: AbilityMode.Targeted,
  );
}

class CardAbilityFireball extends CardAbility {

  @override
  double get range => 200;

  @override
  int get damage => 3;

  CardAbilityFireball() : super(
    type: CardType.Ability_Fireball,
    cooldown: 10,
    mode: AbilityMode.Targeted,
  );
}


class CardPassive extends Card {
  CardPassive(CardType type) : super(type);
}

