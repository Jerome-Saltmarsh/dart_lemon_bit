
enum CardType {
   Weapon_Sword,
   Weapon_Bow,
   Weapon_Staff,
   Ability_Bow_Freeze,
   Ability_Bow_Fire,
   Ability_Bow_Volley,
   Ability_Staff_Explosion,
   Ability_Staff_Heal_10,
   Ability_Staff_Strong_Orb,
   Passive_General_Max_HP_10,
   Passive_General_Critical_Hit,
   Passive_Bow_Run_Speed,
   Passive_Increase_Damage_2,
   Passive_Bow_Split, // Splits arrows that auto aim at nearby multiple nearby targets
}

const cardTypes = CardType.values;

const cardTypeChoicesBow = [
  // ...cardTypesGeneralPassives,
  ...cardTypeBowAbilities,
  // ...cardTypeBowPassives,
];

const cardTypeChoicesStaff = [
  ...cardTypesGeneralPassives,
];

const cardTypeChoicesWarrior = [
  ...cardTypesGeneralPassives,
];

const cardTypesWeapons = <CardType>[
  CardType.Weapon_Sword, 
  CardType.Weapon_Bow, 
  CardType.Weapon_Staff,
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

const cardTypeBowAbilities = <CardType> [
  // CardType.Ability_Bow_Fire,
  // CardType.Ability_Bow_Freeze,
  CardType.Ability_Bow_Volley,
];

const cardTypeBowPassives = <CardType> [
  CardType.Passive_Bow_Run_Speed,
  CardType.Passive_Bow_Split,
];

String getCardTypeName(CardType value) {
   return const <CardType, String> {
      CardType.Weapon_Bow: "Bow",
      CardType.Weapon_Sword: "Sword",
      CardType.Weapon_Staff: "Staff",
      CardType.Ability_Bow_Freeze: "Freeze Arrow",
      CardType.Ability_Bow_Fire: "Fire Arrow",
      CardType.Ability_Bow_Volley: "Volley",
      CardType.Passive_General_Max_HP_10: "Max hp+10",
      CardType.Passive_General_Critical_Hit: "Critical Hit",
      CardType.Passive_Bow_Run_Speed: "Light Feet",
      CardType.Passive_Bow_Split: "Split Arrow",
   }[value] ?? value.name;
}

