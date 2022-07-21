import '../classes/library.dart';
import '../common/library.dart';

Card convertCardTypeToCard(CardType type){

  if (getCardTypeGenre(type) == CardGenre.Passive){
    return CardPassive(type);
  }

  switch(type) {
    case CardType.Ability_Bow_Freeze:
      break;
    case CardType.Ability_Bow_Fire:
      break;
    case CardType.Ability_Bow_Volley:
      return CardAbilityBowVolley();
    case CardType.Ability_Bow_Long_Shot:
      return PowerLongShot();
    case CardType.Ability_Staff_Heal_10:
      break;
    case CardType.Ability_Staff_Strong_Orb:
      break;
    case CardType.Ability_Explosion:
      return CardAbilityExplosion();
    case CardType.Ability_Fireball:
      return PowerFireball();
  }
  throw UnimplementedError('Cannot convert card type $type to card');
}
