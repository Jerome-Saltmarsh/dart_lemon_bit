
import '../common/card_type.dart';
import 'library.dart';

class Card {
   final CardType type;
   Card(this.type);
}

Card convertCardTypeToCard(CardType type){
   switch(type){
      case CardType.Weapon_Sword:
      // TODO: Handle this case.
         break;
      case CardType.Weapon_Bow:
      // TODO: Handle this case.
         break;
      case CardType.Weapon_Staff:
      // TODO: Handle this case.
         break;
      case CardType.Ability_Bow_Freeze:
      // TODO: Handle this case.
         break;
      case CardType.Ability_Bow_Fire:
      // TODO: Handle this case.
         break;
      case CardType.Ability_Bow_Volley:
         return CardAbilityBowVolley();
      case CardType.Ability_Bow_Long_Shot:
         return CardAbilityBowLongShot();
      case CardType.Ability_Staff_Explosion:
      // TODO: Handle this case.
         break;
      case CardType.Ability_Staff_Heal_10:
      // TODO: Handle this case.
         break;
      case CardType.Ability_Staff_Strong_Orb:
      // TODO: Handle this case.
         break;
      case CardType.Passive_General_Max_HP_10:
      // TODO: Handle this case.
         break;
      case CardType.Passive_General_Critical_Hit:
      // TODO: Handle this case.
         break;
      case CardType.Passive_Bow_Run_Speed:
      // TODO: Handle this case.
         break;
      case CardType.Passive_Increase_Damage_2:
      // TODO: Handle this case.
         break;
      case CardType.Passive_Bow_Split:
      // TODO: Handle this case.
         break;
   }
   throw UnimplementedError('Cannot convert card type $type to card');
}
