
enum CardGenre {
  Passive,
  Ability,
}

enum CardType {
   // Weapon_Sword,
   // Weapon_Bow,
   // Weapon_Staff,
   Ability_Bow_Freeze,
   Ability_Bow_Fire,
   Ability_Bow_Volley,
   Ability_Bow_Long_Shot,
   Ability_Staff_Explosion,
   Ability_Staff_Heal_10,
   Ability_Staff_Strong_Orb,
   Passive_General_Max_HP_10,
   Passive_General_Critical_Hit,
   Passive_Bow_Run_Speed,
   Passive_Increase_Damage_2,
}

const cardTypes = CardType.values;

CardGenre getCardTypeGenre(CardType cardType) {
  final genre = const<CardType, CardGenre> {
    CardType.Ability_Staff_Strong_Orb: CardGenre.Ability,
    CardType.Ability_Staff_Heal_10: CardGenre.Ability,
    CardType.Ability_Staff_Explosion: CardGenre.Ability,
    CardType.Ability_Bow_Long_Shot: CardGenre.Ability,
    CardType.Ability_Bow_Freeze: CardGenre.Ability,
    CardType.Ability_Bow_Volley: CardGenre.Ability,
    CardType.Passive_General_Critical_Hit: CardGenre.Passive,
    CardType.Passive_Bow_Run_Speed: CardGenre.Passive,
    CardType.Passive_General_Max_HP_10: CardGenre.Passive,
    CardType.Passive_Increase_Damage_2: CardGenre.Passive,
  }[cardType];
  if(genre == null) throw Exception("$cardType does not have a card genre");
  return genre;
}

const cardTypeChoicesBow = [
  ...cardTypesGeneralPassives,
  ...cardTypeBowAbilities,
  ...cardTypeBowPassives,
];

const cardTypeChoicesStaff = [
  ...cardTypesGeneralPassives,
];

const cardTypeChoicesWarrior = [
  ...cardTypesGeneralPassives,
];

const cardTypesGeneralPassives = <CardType> [
  CardType.Passive_General_Max_HP_10,
  CardType.Passive_General_Critical_Hit,
];

const cardTypeStaffAbilities = <CardType> [
  CardType.Ability_Staff_Explosion,
  CardType.Ability_Staff_Heal_10,
  CardType.Ability_Staff_Strong_Orb,
];

const cardTypeSwordAbilities = <CardType> [
  CardType.Ability_Staff_Explosion,
  CardType.Ability_Staff_Heal_10,
  CardType.Ability_Staff_Strong_Orb,
];

const cardTypeAbilities = [
   ...cardTypeBowAbilities,
   ...cardTypeStaffAbilities,
   ...cardTypeSwordAbilities,
];

const cardTypeBowAbilities = <CardType> [
  // CardType.Ability_Bow_Fire,
  // CardType.Ability_Bow_Freeze,
  CardType.Ability_Bow_Volley,
  CardType.Ability_Bow_Long_Shot,
];

const cardTypeBowPassives = <CardType> [
  CardType.Passive_Bow_Run_Speed,
];

String getCardTypeName(CardType value) {
   return const <CardType, String> {
      CardType.Ability_Bow_Freeze: "Freeze Arrow",
      CardType.Ability_Bow_Fire: "Fire Arrow",
      CardType.Ability_Bow_Volley: "Volley",
      CardType.Ability_Bow_Long_Shot: "Long Shot",
      CardType.Passive_General_Max_HP_10: "Breast Plate",
      CardType.Passive_General_Critical_Hit: "Critical Hit",
      CardType.Passive_Bow_Run_Speed: "Feather Boots",
   }[value] ?? value.name;
}

