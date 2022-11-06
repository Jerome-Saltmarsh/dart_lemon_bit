class ItemType {

  static bool isTypeEmpty(int value) => value == Empty;
  static bool isNotTypeEmpty(int value) => value != Empty;

  static bool isTypeEquipped(int value) =>
    value == Equipped_Weapon ||
    value == Equipped_Head ||
    value == Equipped_Body ||
    value == Equipped_Legs ||
    value == Equipped_Weapon;

  static bool isTypeConsumable(int value) =>
      value >= Index_Consumables && value < Index_Resources;

  static bool isTypeResource(int value) =>
      value >= Index_Resources && value < Index_Heads;

  static bool isTypeHead(int value) =>
    value >= Index_Heads && value < Index_Bodies;

  static bool isTypeBody(int value) =>
      value >= Index_Bodies && value < Index_Legs;

  static bool isTypeLegs(int value) =>
      value >= Index_Legs && value < Index_Weapon_Melee;

  static bool isTypeWeapon(int value) =>
      value >= Index_Weapon_Melee;

  static bool isTypeWeaponMelee(int value) =>
      value == ItemType.Empty || (value >= Index_Weapon_Melee && value < Index_Weapon_Ranged);

  static bool isTypeWeaponRanged(int value) =>
      value >= Index_Weapon_Ranged && value < Index_Equipped;

  static bool isSingleHandedFirearm(int weaponType) =>
      weaponType == Weapon_Ranged_Handgun ||
          weaponType == Weapon_Ranged_Revolver ;

  static bool isTwoHandedFirearm(int weaponType) =>
      weaponType == Weapon_Ranged_Bow ||
          weaponType == Weapon_Ranged_Shotgun ;

  static const Invalid = -1;
  static const Empty = 00000;

  static const Index_Consumables = 00005;
  static const Index_Resources = 05001;
  static const Index_Heads = 10000;
  static const Index_Bodies = 20000;
  static const Index_Legs = 30000;
  static const Index_Weapon_Melee = 40000;
  static const Index_Weapon_Ranged = 45000;
  static const Index_Equipped = 65000;

  static const Index_Equipped_Head = Index_Equipped + 0;
  static const Equipped_Head = Index_Equipped + 1;
  static const Equipped_Body = Index_Equipped + 2;
  static const Equipped_Legs = Index_Equipped + 3;
  static const Equipped_Weapon = Index_Equipped + 4;

  static const Consumable_Health_Potion_05 = Index_Consumables + 0;
  static const Consumable_Health_Potion_10 = Index_Consumables + 1;
  static const Consumable_Health_Potion_20 = Index_Consumables + 2;
  static const Consumable_Health_Potion_40 = Index_Consumables + 3;

  static const Resource_Ammo_9mm = Index_Resources + 1;
  static const Resource_Ammo_Shells = Index_Resources + 2;
  static const Resource_Ammo_Arrows = Index_Resources + 3;
  static const Resource_Ammo_Arrows_Iron_Tip = Index_Resources + 3;
  static const Resource_Ammo_Arrows_Silver = Index_Resources + 3;
  static const Resource_Ammo_Arrows_Fire = Index_Resources + 3;
  static const Resource_Ammo_Bolts = Index_Resources + 4;

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
      Empty: 1,
      Weapon_Ranged_Handgun: 2,
      Weapon_Ranged_Shotgun: 2,
  }[value] ?? 0;

  static double getRange(int value) => <int, double> {
      Empty: 50,
      Weapon_Ranged_Handgun: 200,
      Weapon_Ranged_Shotgun: 100,
  }[value] ?? 0;

  static int getCooldown(int value) => {
      Weapon_Ranged_Handgun: 20,
      Weapon_Ranged_Shotgun: 40,
  }[value] ?? 30;
  
  static String getName(int value) => {
     Empty: "Empty",
     Weapon_Ranged_Shotgun: "Shotgun",
     Weapon_Ranged_Handgun: "Handgun",
     Resource_Ammo_9mm: "Ammo 9mm",
     Resource_Ammo_Shells: "Shells",
     Resource_Ammo_Arrows: "Arrows",
     Legs_Brown: "Pants Brown",
     Legs_Swat: "Pants Swat",
     Legs_Green: "Pants Green",
     Legs_Blue: "Pants Blue",
     Legs_White: "Pants White",
     Legs_Red: "Pants Red",
  }[value] ?? "item-type-unknown($value)";
}
