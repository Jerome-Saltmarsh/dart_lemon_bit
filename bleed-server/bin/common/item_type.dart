class ItemType {

  static bool isTypeEmpty(int value) => value == Empty;

  static bool isTypeConsumable(int value) =>
      value >= Index_Consumables && value < Index_Heads;

  static bool isTypeHead(int value) =>
    value >= Index_Heads && value < Index_Bodies;

  static bool isTypeBody(int value) =>
      value >= Index_Bodies && value < Index_Legs;

  static bool isTypeLegs(int value) =>
      value >= Index_Legs && value < Index_Weapon_Melee;

  static bool isTypeWeapon(int value) =>
      value >= Index_Weapon_Melee;

  static bool isTypeWeaponMelee(int value) =>
      value >= Index_Weapon_Melee && value < Index_Weapon_Ranged;

  static bool isTypeWeaponRanged(int value) =>
      value >= Index_Weapon_Ranged;

  static bool isSingleHandedFirearm(int weaponType) =>
      weaponType == Weapon_Ranged_Handgun ||
          weaponType == Weapon_Ranged_Revolver ;

  static bool isTwoHandedFirearm(int weaponType) =>
      weaponType == Weapon_Ranged_Bow ||
          weaponType == Weapon_Ranged_Shotgun ;

  static const Empty = 0;
  static const Index_Consumables = 00001;
  static const Index_Heads = 10000;
  static const Index_Bodies = 20000;
  static const Index_Legs = 30000;
  static const Index_Weapon_Melee = 40000;
  static const Index_Weapon_Ranged = 45000;

  // static const Consumable = 0;
  // static const Head = 1;
  // static const Body = 2;
  // static const Pants = 3;
  // static const Weapon = 4;

  static const Consumable_Health_Potion_05 = Index_Consumables + 0;
  static const Consumable_Health_Potion_10 = Index_Consumables + 1;
  static const Consumable_Health_Potion_20 = Index_Consumables + 2;
  static const Consumable_Health_Potion_40 = Index_Consumables + 3;

  static const Head_Steel_Helm = Index_Heads + 1;
  static const Head_Rogues_Hood = Index_Heads + 2;
  static const Head_Wizards_Hat = Index_Heads + 3;
  static const Head_Blonde = Index_Heads + 4;
  static const Head_Swat = Index_Heads + 5;

  static const Body_Shirt_Cyan = Index_Bodies + 1;
  static const Body_Shirt_Blue = Index_Bodies + 2;
  static const Body_Tunic_Padded = Index_Bodies + 3;
  static const Body_Swat = Index_Bodies + 4;

  static const Legs_Brown = Index_Legs + 1;
  static const Legs_Blue = Index_Legs + 2;
  static const Legs_Red = Index_Legs + 3;
  static const Legs_Green = Index_Legs + 4;
  static const Legs_White = Index_Legs + 5;
  static const Legs_Swat = Index_Legs + 6;

  static const Weapon_Ranged_Handgun = Index_Weapon_Ranged + 1;
  static const Weapon_Ranged_Revolver = Index_Weapon_Ranged + 2;
  static const Weapon_Ranged_Shotgun = Index_Weapon_Ranged + 3;
  static const Weapon_Ranged_Bow = Index_Weapon_Ranged + 4;
  static const Weapon_Ranged_Crossbow = Index_Weapon_Ranged + 5;
  static const Weapon_Ranged_Assault_Rifle = Index_Weapon_Ranged + 6;
  static const Weapon_Ranged_Rifle = Index_Weapon_Ranged + 7;
  static const Weapon_Ranged_Staff_Of_Flames = Index_Weapon_Ranged + 8;
  static const Weapon_Melee_Magic_Staff = Index_Weapon_Ranged + 9;

  static const Weapon_Melee_Sword = Index_Weapon_Melee + 1;
  static const Weapon_Melee_Sword_Rusty = Index_Weapon_Melee + 2;
  static const Weapon_Melee_Crowbar = Index_Weapon_Melee + 3;
  static const Weapon_Melee_Pickaxe = Index_Weapon_Melee + 4;
  static const Weapon_Melee_Axe = Index_Weapon_Melee + 5;
  static const Weapon_Melee_Hammer = Index_Weapon_Melee + 6;


  static int getDamage(int value) => {
      Weapon_Ranged_Handgun: 2,
      Weapon_Ranged_Shotgun: 2,
  }[value] ?? 0;

  static double getRange(int value) => <int, double> {
      Weapon_Ranged_Handgun: 2,
      Weapon_Ranged_Shotgun: 2,
  }[value] ?? 0;

  static int getCooldown(int value) => {
      Weapon_Ranged_Handgun: 20,
      Weapon_Ranged_Shotgun: 40,
  }[value] ?? 0;
  
  static String getName(int value) => {
    
  }[0] ?? "item-type-unknown($value)";
}
