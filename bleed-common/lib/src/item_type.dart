class ItemType {

  static bool isTypeEmpty(int value) => value == Empty;
  static bool isNotTypeEmpty(int value) => value != Empty;

  static bool isPersistable(int value) =>
      isTypeEnvironment(value);

  static bool isCollidable(int value) {
     return value == ItemType.GameObjects_Crystal;
  }

  static bool isTypeEquipped(int value) =>
    value == Equipped_Weapon ||
    value == Equipped_Head ||
    value == Equipped_Body ||
    value == Equipped_Legs ||
    value == Equipped_Weapon;

  static int getSellPrice(int itemType) =>
    getBuyPrice(itemType) ~/ 10;

  static int getBuyPrice(int itemType) => const {
     Resource_Gun_Powder: 25,
     Resource_Arrow: 20,
     Legs_Brown: 100,
     Legs_Blue: 100,
     Head_Wizards_Hat: 500,
     Head_Rogues_Hood: 500,
     Head_Steel_Helm: 1000,
     Consumables_Apple: 30,
     Consumables_Meat: 50,
  }[itemType] ?? 0;

  static bool isTypeEquippable(int value) =>
      isTypeBody(value) ||
      isTypeHead(value) ||
      isTypeLegs(value) ||
      isTypeWeapon(value);

  
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
      value >= Index_Weapon_Melee && value < Index_Recipe;

  static bool isTypeWeaponMelee(int value) =>
      value == ItemType.Empty || (value >= Index_Weapon_Melee && value < Index_Weapon_Ranged);

  static bool isTypeWeaponRanged(int value) =>
      value >= Index_Weapon_Ranged && value < Index_Recipe;

  static bool isIndexBelt(int index)=> index >= Belt_1 && index <= Belt_6;

  static bool isTypeRecipe(int value) =>
      value >= Index_Recipe && value < Index_Equipped;

  static bool isSingleHandedFirearm(int weaponType) =>
      weaponType == Weapon_Ranged_Handgun ||
      weaponType == Weapon_Ranged_Revolver ;

  static bool isTwoHandedFirearm(int weaponType) =>
      weaponType == Weapon_Ranged_Bow ||
      weaponType == Weapon_Ranged_Shotgun ;

  static const Invalid              = -0001;
  static const Empty                = 00000;
  static const Index_Environment    = 01000;
  static const Index_Consumables    = 02000;
  static const Index_Resources      = 05000;
  static const Index_Heads          = 10000;
  static const Index_Bodies         = 20000;
  static const Index_Legs           = 30000;
  static const Index_Weapon_Melee   = 40000;
  static const Index_Weapon_Ranged  = 45000;
  static const Index_Recipe         = 50000;
  static const Index_Belt       = 65000;
  static const Index_Equipped       = Index_Belt + 7;

  static const Belt_1 = Index_Belt + 1;
  static const Belt_2 = Index_Belt + 2;
  static const Belt_3 = Index_Belt + 3;
  static const Belt_4 = Index_Belt + 4;
  static const Belt_5 = Index_Belt + 5;
  static const Belt_6 = Index_Belt + 6;

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
  static const Resource_Gold = Index_Resources + 9;
  static const Resource_Gun_Powder = Index_Resources + 10;
  static const Resource_Arrow = Index_Resources + 11;

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
  static const Weapon_Ranged_Harquebus = Index_Weapon_Ranged + 6;
  static const Weapon_Ranged_Musket = Index_Weapon_Ranged + 6;
  static const Weapon_Ranged_Blunderbuss = Index_Weapon_Ranged + 6;
  static const Weapon_Ranged_Rifle = Index_Weapon_Ranged + 7;
  static const Weapon_Ranged_Flintlock_Pistol = Index_Weapon_Ranged + 7;
  static const Weapon_Ranged_Staff_Of_Flames = Index_Weapon_Ranged + 8;
  static const Weapon_Melee_Magic_Staff = Index_Weapon_Ranged + 9;

  static const Weapon_Melee_Sword = Index_Weapon_Melee + 1;
  static const Weapon_Melee_Sword_Rusty = Index_Weapon_Melee + 2;
  static const Weapon_Melee_Crowbar = Index_Weapon_Melee + 3;
  static const Weapon_Melee_Pickaxe = Index_Weapon_Melee + 4;
  static const Weapon_Melee_Axe = Index_Weapon_Melee + 5;
  static const Weapon_Melee_Hammer = Index_Weapon_Melee + 6;
  static const Recipe_Staff_Of_Fire = Index_Recipe + 1;

  static bool isFood(int type) =>
     type == Consumables_Apple ||
     type == Consumables_Meat ;
  
  static bool isCollectable(int type){
    return type >= Index_Consumables;
  }

  static int getConsumeType(int itemType) => const {
      Weapon_Ranged_Handgun: Resource_Gun_Powder,
      Weapon_Ranged_Shotgun: Resource_Gun_Powder,
      Weapon_Ranged_Bow: Resource_Arrow,
  }[itemType] ?? Empty;

  static int getConsumeAmount(int itemType) => const {
    Weapon_Ranged_Bow: 1,
    Weapon_Ranged_Handgun: 1,
    Weapon_Ranged_Shotgun: 3,
  }[itemType] ?? 0;

  static const Recipes = {
    Recipe_Staff_Of_Fire : [
      Resource_Wood, 50,
      Resource_Crystal, 50,
    ],
  };

  static int getDamage(int value) => {
      Empty: 1,
      Weapon_Ranged_Handgun: 2,
      Weapon_Ranged_Shotgun: 2,
      Weapon_Melee_Magic_Staff: 2,
      Weapon_Ranged_Staff_Of_Flames: 2,
  }[value] ?? 0;

  static double getRange(int value) => <int, double> {
      Empty: 50,
      Weapon_Ranged_Handgun: 200,
      Weapon_Ranged_Shotgun: 100,
      Weapon_Ranged_Staff_Of_Flames: 100,
      Weapon_Melee_Magic_Staff: 100,
  }[value] ?? 0;

  static int getCooldown(int value) => {
      Weapon_Ranged_Handgun: 20,
      Weapon_Ranged_Shotgun: 40,
  }[value] ?? 30;

  static String getGroupTypeName(int value) {
     if (isTypeEmpty(value)) return "Empty";
     if (isTypeEquipped(value)) return "Equipped";
     if (isTypeConsumable(value)) return "Consumable";
     if (isTypeResource(value)) return "Resource";
     if (isTypeHead(value)) return "Headpiece";
     if (isTypeLegs(value)) return "Pants";
     if (isTypeBody(value)) return "Body";
     if (isTypeWeaponRanged(value)) return "Ranged Weapon";
     if (isTypeWeaponMelee(value)) return "Melee Weapon";
     if (isTypeRecipe(value)) return "Recipe";
     return "item-type-group-unknown-$value";
  }
  
  static String getName(int value) => {
     Empty: "Empty",
     Weapon_Ranged_Shotgun: "Shotgun",
     Weapon_Ranged_Handgun: "Handgun",
     Weapon_Melee_Magic_Staff: "Magic Staff",
     Weapon_Ranged_Staff_Of_Flames: "Staff of Flames",
     Resource_Crystal: "Crystal",
     Resource_Wood: "Wood",
     Resource_Iron: "Iron",
     Resource_Stone: "Stone",
     Resource_Gold: "Gold",
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
     Recipe_Staff_Of_Fire: "Staff of Fire",
     Consumables_Apple: "Apple",
     Consumables_Meat: "Meat",
  }[value] ?? "item-type-unknown($value)";
}
