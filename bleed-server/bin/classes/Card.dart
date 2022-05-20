
import '../common/card_type.dart';
import 'library.dart';

class Card {
   final CardType type;
   Card(this.type);
}

Card convertCardTypeToCard(CardType type){

   if (getCardTypeGenre(type) == CardGenre.Passive){
      return CardPassive(type);
   }

   switch(type){
      case CardType.Weapon_Sword:
         break;
      case CardType.Weapon_Bow:
         break;
      case CardType.Weapon_Staff:
         break;
      case CardType.Ability_Bow_Freeze:
         break;
      case CardType.Ability_Bow_Fire:
         break;
      case CardType.Ability_Bow_Volley:
         return CardAbilityBowVolley();
      case CardType.Ability_Bow_Long_Shot:
         return CardAbilityBowLongShot();
      case CardType.Ability_Staff_Explosion:
         break;
      case CardType.Ability_Staff_Heal_10:
         break;
      case CardType.Ability_Staff_Strong_Orb:
         break;
   }
   throw UnimplementedError('Cannot convert card type $type to card');
}
