class ItemType {

  static const Invalid                      = -0001;
  static const Empty                        = 00000;
  static const Index_Environment            = 01000;
  static const Index_Consumables            = 02000;
  static const Index_Resources              = 05000;
  static const Index_Heads                  = 10000;
  static const Index_Bodies                 = 20000;
  static const Index_Legs                   = 30000;
  static const Index_Weapon_Melee           = 40000;
  static const Index_Weapon_Ranged_Handgun  = 45000;
  static const Index_Weapon_Ranged_Rifle    = 46000;
  static const Index_Weapon_Ranged_Shotgun  = 47000;
  static const Index_Weapon_Ranged_Bow      = 48000;
  static const Index_Weapon_Ranged_Crossbow = 49000;
  static const Index_Recipe                 = 50000;
  static const Index_Belt                   = 65000;
  static const Index_Equipped               = Index_Belt + 7;

  static const Belt_1 = Index_Belt + 1;
  static const Belt_2 = Index_Belt + 2;
  static const Belt_3 = Index_Belt + 3;
  static const Belt_4 = Index_Belt + 4;
  static const Belt_5 = Index_Belt + 5;
  static const Belt_6 = Index_Belt + 6;

  static const Belt_Indexes = [Belt_1, Belt_2, Belt_3, Belt_4, Belt_5, Belt_6];

  static const Equipped_Head = Index_Equipped + 1;
  static const Equipped_Body = Index_Equipped + 2;
  static const Equipped_Legs = Index_Equipped + 3;
  static const Equipped_Weapon = Index_Equipped + 4;

  static const Consumables_Apple = Index_Consumables + 1;
  static const Consumables_Meat = Index_Consumables + 2;
  static const Consumables_Potion_Red = Index_Consumables + 3;

  static const GameObjects_Flower = Index_Environment + 1;
  static const GameObjects_Rock = Index_Environment + 2;
  static const GameObjects_Stick = Index_Environment + 3;
  static const GameObjects_Barrel = Index_Environment + 4;
  static const GameObjects_Tavern_Sign = Index_Environment + 5;
  static const GameObjects_Candle = Index_Environment + 6;
  static const GameObjects_Bottle = Index_Environment + 7;
  static const GameObjects_Wheel = Index_Environment + 8;
  static const GameObjects_Crystal = Index_Environment + 9;
  static const GameObjects_Cup = Index_Environment + 10;
  static const GameObjects_Lantern_Red = Index_Environment + 11;
  static const GameObjects_Book_Purple = Index_Environment + 12;
  static const GameObjects_Crystal_Small_Blue = Index_Environment + 13;

  static const Resource_Wood = Index_Resources + 5;
  static const Resource_Stone = Index_Resources + 6;
  static const Resource_Crystal = Index_Resources + 7;
  static const Resource_Iron = Index_Resources + 8;
  static const Resource_Scrap_Metal = Index_Resources + 9;
  static const Resource_Gold = Index_Resources + 10;
  static const Resource_Gun_Powder = Index_Resources + 11;
  static const Resource_Arrow = Index_Resources + 12;

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

  static const Weapon_Melee_Staff = Index_Weapon_Melee + 1;
  static const Weapon_Melee_Staff_Of_Flames = Weapon_Melee_Staff + 1;
  static const Weapon_Melee_Sword = Weapon_Melee_Staff_Of_Flames + 1;
  static const Weapon_Melee_Sword_Rusty = Weapon_Melee_Sword + 1;
  static const Weapon_Melee_Crowbar = Weapon_Melee_Sword_Rusty + 1;
  static const Weapon_Melee_Pickaxe = Weapon_Melee_Crowbar + 1;
  static const Weapon_Melee_Axe = Weapon_Melee_Pickaxe + 1;
  static const Weapon_Melee_Hammer = Weapon_Melee_Axe + 1;

  static const Weapon_Handgun_Flint_Lock_Old = Index_Weapon_Ranged_Handgun + 1;
  static const Weapon_Handgun_Flint_Lock = Weapon_Handgun_Flint_Lock_Old + 1;
  static const Weapon_Handgun_Flint_Lock_Superior = Weapon_Handgun_Flint_Lock + 1;
  static const Weapon_Handgun_Blunderbuss = Weapon_Handgun_Flint_Lock_Superior + 1;
  static const Weapon_Handgun_Revolver = Weapon_Handgun_Blunderbuss + 1;
  static const Weapon_Handgun_Glock = Weapon_Handgun_Revolver + 1;

  static const Weapon_Rifle_Arquebus = Index_Weapon_Ranged_Rifle + 1;
  static const Weapon_Rifle_Blunderbuss = Weapon_Rifle_Arquebus + 1;
  static const Weapon_Rifle_Musket = Weapon_Rifle_Blunderbuss + 1;
  static const Weapon_Rifle_Jager = Weapon_Rifle_Musket + 1;
  static const Weapon_Rifle_Assault = Weapon_Rifle_Jager + 1;

  static const Weapon_Ranged_Shotgun = Index_Weapon_Ranged_Shotgun + 1;

  static const Weapon_Ranged_Bow = Index_Weapon_Ranged_Bow + 1;
  static const Weapon_Ranged_Bow_Long = Weapon_Ranged_Bow + 1;
  static const Weapon_Ranged_Crossbow = Weapon_Ranged_Bow_Long + 1;


  static const Recipes = <int, List<int>> {
    Weapon_Handgun_Flint_Lock: const [
      0001, Weapon_Handgun_Flint_Lock_Old,
      0100, Resource_Scrap_Metal,
      0050, Resource_Gold,
    ],
    Weapon_Handgun_Flint_Lock_Superior: const [
      0003, Weapon_Handgun_Flint_Lock,
      0400, Resource_Scrap_Metal,
      0100, Resource_Gold,
    ],
    Weapon_Handgun_Blunderbuss: const [
      0003, Weapon_Handgun_Flint_Lock_Superior,
      0400, Resource_Scrap_Metal,
      0100, Resource_Gold,
    ],
    Weapon_Handgun_Revolver: const [
      0003, Weapon_Handgun_Blunderbuss,
      0400, Resource_Scrap_Metal,
      0100, Resource_Gold,
    ],
    Weapon_Handgun_Glock: const [
      0003, Weapon_Handgun_Blunderbuss,
      0400, Resource_Scrap_Metal,
      0100, Resource_Gold,
    ],
  };

  static bool isTypeEmpty(int value) => value == Empty;
  static bool isNotTypeEmpty(int value) => value != Empty;

  static bool isPersistable(int value) =>
      isTypeEnvironment(value);

  static bool isCollidable(int value) =>
    value == ItemType.GameObjects_Crystal;

  static bool isTypeEquipped(int value) =>
    value == Equipped_Weapon  ||
    value == Equipped_Head    ||
    value == Equipped_Body    ||
    value == Equipped_Legs    ;

  static bool isTypeEquippable(int value) =>
    isTypeBody(value)         ||
    isTypeHead(value)         ||
    isTypeLegs(value)         ||
    isTypeWeapon(value)       ;

  static bool isTypeEnvironment(int value) =>
      value >= Index_Environment && value < Index_Consumables;

  static bool isTypeConsumable(int value) =>
      value >= Index_Consumables && value < Index_Resources;

  static bool isTypeResource(int value) =>
      value >= Index_Resources && value < Index_Heads;

  static bool isTypeHead(int value) =>
    value >= Index_Heads && value < Index_Bodies;

  static bool isTypeHeadOrEmpty(int value) =>
      isTypeHead(value) || value == Empty;

  static bool isTypeBody(int value) =>
      value >= Index_Bodies && value < Index_Legs;

  static bool isTypeLegs(int value) =>
      value >= Index_Legs && value < Index_Weapon_Melee;

  static bool isTypeWeapon(int value) =>
      value > Index_Weapon_Melee && value < Index_Recipe;

  static bool isTypeWeaponFirearm(int value) =>
      value >= Index_Weapon_Ranged_Handgun && value < Index_Weapon_Ranged_Bow;

  static bool isTypeWeaponMelee(int value) =>
      value == ItemType.Empty || (value > Index_Weapon_Melee && value < Index_Weapon_Ranged_Handgun);

  static bool isTypeWeaponHandgun(int value) =>
      value > Index_Weapon_Ranged_Handgun && value < Index_Weapon_Ranged_Rifle;

  static bool isTypeWeaponRifle(int value) =>
      value > Index_Weapon_Ranged_Rifle && value < Index_Weapon_Ranged_Shotgun;

  static bool isTypeWeaponShotgun(int value) =>
      value > Index_Weapon_Ranged_Shotgun && value < Index_Weapon_Ranged_Bow;

  static bool isTypeWeaponRanged(int value) =>
      value >= Index_Weapon_Ranged_Handgun && value < Index_Recipe;

  static bool isIndexBelt(int index)=> index >= Belt_1 && index <= Belt_6;

  static bool isTypeRecipe(int value) =>
      value >= Index_Recipe && value < Index_Equipped;

  static bool isSingleHandedFirearm(int weaponType) =>
      isTypeWeaponHandgun(weaponType);

  static bool isTwoHandedFirearm(int weaponType) =>
      weaponType == Weapon_Ranged_Bow ||
      weaponType == Weapon_Ranged_Shotgun ;

  static bool isFood(int type) =>
     type == Consumables_Apple ||
     type == Consumables_Meat ;
  
  static bool isCollectable(int type){
    return type >= Index_Consumables;
  }

  static bool doesConsumeOnUse(int itemType){
     return getConsumeAmount(itemType) > 0;
  }
  
  static int getConsumeType(int itemType) {

    if (isTypeWeaponHandgun(itemType)){
      return Resource_Gun_Powder;
    }

    if (isTypeWeaponHandgun(itemType)){
      return Resource_Gun_Powder;
    }

    return const {
      Weapon_Ranged_Shotgun: Resource_Gun_Powder,
      Weapon_Ranged_Bow: Resource_Arrow,
  }[itemType] ?? Empty;
  }

  static int getConsumeAmount(int itemType) => const {
    Weapon_Ranged_Bow: 1,
    Weapon_Handgun_Glock: 1,
    Weapon_Ranged_Shotgun: 3,
    Weapon_Handgun_Flint_Lock_Old: 1,
    Weapon_Handgun_Flint_Lock: 1,
    Weapon_Handgun_Flint_Lock_Superior: 1,
  }[itemType] ?? 0;

  static int getDamage(int value) => const {
      Empty: 1,
      Weapon_Ranged_Shotgun: 2,
      Weapon_Handgun_Flint_Lock_Old: 1,
      Weapon_Handgun_Flint_Lock: 2,
      Weapon_Handgun_Flint_Lock_Superior: 3,
  }[value] ?? 0;

  static double getRange(int value) => const <int, double> {
      Empty: 50,
      Weapon_Ranged_Shotgun: 90,
      Weapon_Handgun_Flint_Lock_Old: 100,
      Weapon_Handgun_Flint_Lock: 110,
      Weapon_Handgun_Flint_Lock_Superior: 120,
  }[value] ?? 0;

  static int getCooldown(int value) => const {
      Empty: 40,
      Weapon_Ranged_Shotgun: 40,
      Weapon_Handgun_Flint_Lock_Old: 50,
      Weapon_Handgun_Flint_Lock: 45,
      Weapon_Handgun_Flint_Lock_Superior: 40,
  }[value] ?? 0;

  static String getGroupTypeName(int value) {
    if (isTypeEmpty(value))
      return "Empty";
     if (isTypeWeapon(value))
       return "Weapon";
     if (isTypeEquipped(value))
       return "Equipped";
     if (isTypeConsumable(value))
       return "Consumable";
     if (isTypeResource(value))
       return "Resource";
     if (isTypeHead(value))
       return "Headpiece";
     if (isTypeLegs(value))
       return "Pants";
     if (isTypeBody(value))
       return "Body";
     if (isTypeRecipe(value))
       return "Recipe";
     return "item-type-group-unknown-$value";
  }
  
  static String getName(int value) => const {
     Empty: "Empty",
     Resource_Crystal: "Crystal",
     Resource_Wood: "Wood",
     Resource_Iron: "Iron",
     Resource_Stone: "Stone",
     Resource_Gold: "Gold",
     Resource_Scrap_Metal: "Scrap Metal",
     Resource_Gun_Powder: "Gun-Powder",
     Resource_Arrow: "Arrow",
     Head_Wizards_Hat: "Wizards Hat",
     Head_Steel_Helm: "Steel Helm",
     Head_Rogues_Hood: "Rogues Hood",
     Head_Blonde: "Head Blonde",
     Head_Swat: "Head Swat",
     Body_Shirt_Cyan: "Cyan Shirt",
     Body_Shirt_Blue: "Blue Shirt",
     Body_Tunic_Padded: "Padded Tunic",
     Body_Swat: "Tactical Vest",
     Legs_Brown: "Brown Pants",
     Legs_Swat: "Tactical Pants",
     Legs_Green: "Green Pants",
     Legs_Blue: "Blue Vest",
     Legs_White: "White Pants",
     Legs_Red: "Red Trousers",
     Weapon_Melee_Staff: "Staff",
     Weapon_Handgun_Flint_Lock_Old: "Old Flint Lock Pistol",
     Weapon_Handgun_Flint_Lock: "Flint Lock Pistol",
     Weapon_Handgun_Flint_Lock_Superior: "Superior Flint Lock Pistol",
     Weapon_Handgun_Blunderbuss: "Blunderbuss Pistol",
     Weapon_Handgun_Glock: "Glock 22",
     Weapon_Handgun_Revolver: "Revolver",
     Weapon_Ranged_Shotgun: "Shotgun",
     Consumables_Apple: "Apple",
     Consumables_Meat: "Meat",
  }[value] ?? "item-type-unknown($value)";

  static int getMaxQuantity(int itemType) => const {
    Resource_Gun_Powder: 100,
    Resource_Arrow:     100,
  }[itemType] ??        01;

  static int getHealAmount(int itemType) => const {
    Consumables_Apple:  03,
    Consumables_Meat:   05,
  }[itemType] ??        00;

  static int getMaxHealth(int itemType) => const {
    Head_Steel_Helm     : 10,
    Head_Rogues_Hood    : 05,
    Head_Wizards_Hat    : 03,
    Head_Swat           : 15,
    Head_Blonde         : 08,
    Body_Swat           : 40,
    Body_Tunic_Padded   : 50,
    Body_Shirt_Blue     : 10,
    Body_Shirt_Cyan     : 15,
    Legs_Blue           : 10,
    Legs_Brown          : 15,
    Legs_Red            : 20,
    Legs_White          : 25,
    Legs_Green          : 30,
  }[itemType] ??          00;
}


