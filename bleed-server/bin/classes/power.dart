import 'package:lemon_math/library.dart';

import '../common/AbilityMode.dart';
import '../common/card_type.dart';
import '../common/library.dart';
import 'card.dart';
import 'character.dart';
import 'game.dart';

abstract class Power extends Card {
  int cooldownRemaining = 0;
  int cooldown;
  AbilityMode mode;

  double get range;
  int get damage;
  double get radius => 0;
  int get duration => 30;

  bool get isModeArea => mode == AbilityMode.Area;

  Power({
    required CardType type,
    required this.cooldown,
    required this.mode,
  }) :super(type);

  void update() {}

  void onActivated(Character src, Game game){

  }
}


class CardAbilityExplosion extends Power {

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

class CardAbilityBowVolley extends Power {

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

class PowerLongShot extends Power {

  @override
  double get range => 300;

  @override
  int get damage => 10 + (level * 5);

  PowerLongShot() : super(
      type: CardType.Ability_Bow_Long_Shot,
      cooldown: 20,
      mode: AbilityMode.Targeted,
  );
}

class PowerFireball extends Power {

  @override
  double get range => 200;

  @override
  int get damage => 3;

  PowerFireball() : super(
    type: CardType.Ability_Fireball,
    cooldown: 10,
    mode: AbilityMode.Targeted,
  );

  @override
  void onActivated(Character src, Game game) {
    if (src.stateDuration != 10) return;
    final piSixteenth = piEighth * 0.5;
    game.spawnProjectileFireball(src, damage: damage, range: range);
    game.spawnProjectileFireball(src, damage: damage, range: range, angle: src.angle + piSixteenth);
    game.spawnProjectileFireball(src, damage: damage, range: range, angle: src.angle - piSixteenth);
    src.clearAbility();
  }
}

class PowerStunStrike extends Power {
  PowerStunStrike() : super(type: CardType.Power_Stun_Strike, cooldown: 100, mode: AbilityMode.Targeted);

  int get damage => 5;

  @override
  double get range => 100;

  @override
  void onActivated(Character src, Game game) {
    src.clearAbility();
  }
}


class CardPassive extends Card {
  CardPassive(CardType type) : super(type);
}

