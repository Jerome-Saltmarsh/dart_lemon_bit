

enum CardType {
   Weapon_Sword,
   Weapon_Bow,
   Weapon_Axe,
   Weapon_Staff,
   Ability_Bow_Split,
   Ability_Bow_Freeze,
   Ability_Bow_Fire,
   Passive_General_Max_HP_10,
   Passive_Bow_Run_Speed,
}

const cardTypes = CardType.values;

const cardTypeChoicesBow = [
  ...cardTypesGeneralPassives,
  ...cardTypeBowAbilities,
  ...cardTypeBowPassives,
];

const cardTypesWeapons = <CardType>[
  CardType.Weapon_Sword, 
  CardType.Weapon_Bow, 
  CardType.Weapon_Axe, 
  CardType.Weapon_Staff, 
];

const cardTypesGeneralPassives = <CardType> [
  CardType.Passive_General_Max_HP_10,
];

const cardTypeBowAbilities = <CardType> [
  CardType.Ability_Bow_Fire,
  CardType.Ability_Bow_Freeze,
  CardType.Ability_Bow_Split,
];

const cardTypeBowPassives = <CardType> [
  CardType.Passive_Bow_Run_Speed,
];


String getCardTypeName(CardType value) {
   return const <CardType, String> {
      CardType.Weapon_Axe: "Axe",
      CardType.Weapon_Bow: "Bow",
      CardType.Weapon_Sword: "Sword",
      CardType.Weapon_Staff: "Staff",
      CardType.Ability_Bow_Split: "Split Arrow",
      CardType.Ability_Bow_Freeze: "Freeze Arrow",
      CardType.Ability_Bow_Fire: "Fire Arrow",
      CardType.Passive_General_Max_HP_10: "Max hp+10",
      CardType.Passive_Bow_Run_Speed: "Light Feet",
   }[value] ?? value.name;
}

