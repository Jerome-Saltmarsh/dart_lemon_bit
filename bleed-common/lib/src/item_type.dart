
///
class ItemType {

  static const Invalid                      = -0001;
  static const Empty                        = 00000;
  static const Index_Perk                   = 00500;
  static const Index_Base                   = 00800;
  static const Index_GameObjects            = 01000;
  static const Index_Consumables            = 02000;
  static const Index_Resources              = 05000;
  static const Index_Trinkets               = 07000;
  static const Index_Heads                  = 10000;
  static const Index_Bodies                 = 20000;
  static const Index_Legs                   = 30000;
  static const Index_Weapon_Melee           = 40000;
  static const Index_Weapon_Thrown          = 42500;
  static const Index_Weapon_Ranged_Handgun  = 45000;
  static const Index_Weapon_Ranged_Rifle    = 46000;
  static const Index_Weapon_Ranged_Smg      = 46500;
  static const Index_Weapon_Ranged_Shotgun  = 47000;
  static const Index_Weapon_Ranged_Bow      = 48000;
  static const Index_Weapon_Ranged_Crossbow = 49000;
  static const Index_Weapon_Special         = 49200;
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

  static const Perk_Max_Health        = Index_Perk + 1;
  static const Perk_Damage            = Perk_Max_Health + 1;

  static const Base_Health            = Index_Base + 1;
  static const Base_Damage            = Base_Health + 2;
  static const Base_Energy            = Base_Health + 3;

  static const Consumables_Apple        = Index_Consumables + 1;
  static const Consumables_Meat         = Index_Consumables + 2;
  static const Consumables_Potion_Red   = Index_Consumables + 3;
  static const Consumables_Potion_Blue  = Index_Consumables + 4;

  static const Trinket_Ring_of_Health   = Index_Trinkets;
  static const Trinket_Ring_of_Damage   = Trinket_Ring_of_Health + 1;
  /// Causes the flame thrower damage to be +5
  /// Does not stack
  /// Does not stack means that the effects only apply to up to one time
  /// Buying a second would not add any additional effects
  /// Boots 
  /// Boots can give the player special powers
  static const Trinket_Gem_of_Fire = Trinket_Ring_of_Health + 2;

  static const GameObjects_Flower               = Index_GameObjects + 01;
  static const GameObjects_Rock                 = Index_GameObjects + 02;
  static const GameObjects_Stick                = Index_GameObjects + 03;
  static const GameObjects_Barrel               = Index_GameObjects + 04;
  static const GameObjects_Tavern_Sign          = Index_GameObjects + 05;
  static const GameObjects_Candle               = Index_GameObjects + 06;
  static const GameObjects_Bottle               = Index_GameObjects + 07;
  static const GameObjects_Wheel                = Index_GameObjects + 08;
  static const GameObjects_Crystal              = Index_GameObjects + 09;
  static const GameObjects_Cup                  = Index_GameObjects + 10;
  static const GameObjects_Lantern_Red          = Index_GameObjects + 11;
  static const GameObjects_Book_Purple          = Index_GameObjects + 12;
  static const GameObjects_Crystal_Small_Blue   = Index_GameObjects + 13;
  static const GameObjects_Crystal_Small_Red    = Index_GameObjects + 14;
  static const GameObjects_Grenade              = Index_GameObjects + 15;
  static const GameObjects_Car                  = Index_GameObjects + 16;
  static const GameObjects_Node_Collider        = Index_GameObjects + 17;
  static const GameObjects_Barrel_Explosive     = Index_GameObjects + 18;
  static const GameObjects_Barrel_Purple        = Index_GameObjects + 19;
  static const GameObjects_Barrel_Flaming       = Index_GameObjects + 20;

  static const Resource_Wood = Index_Resources + 5;
  static const Resource_Stone = Index_Resources + 6;
  static const Resource_Crystal = Index_Resources + 7;
  static const Resource_Iron = Index_Resources + 8;
  static const Resource_Scrap_Metal = Index_Resources + 9;
  static const Resource_Gold = Index_Resources + 10;
  static const Resource_Gun_Powder = Index_Resources + 11;
  static const Resource_Arrow = Index_Resources + 12;
  static const Resource_Round_9mm = Index_Resources + 13;
  static const Resource_Round_50cal = Index_Resources + 14;
  static const Resource_Round_Rifle = Index_Resources + 15;
  static const Resource_Round_Shotgun = Index_Resources + 16;
  static const Resource_Fuel = Index_Resources + 17;
  static const Resource_Rocket = Index_Resources + 18;

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
  static const Weapon_Melee_Knife = Weapon_Melee_Hammer + 1;

  static const Weapon_Thrown_Pike_Bomb = Index_Weapon_Thrown + 1;
  static const Weapon_Thrown_Grenade = Index_Weapon_Thrown + 2;
  static const Weapon_Thrown_Molotov_Cocktail = Index_Weapon_Thrown + 3;

  static const Weapon_Handgun_Flint_Lock_Old = Index_Weapon_Ranged_Handgun + 1;
  static const Weapon_Handgun_Flint_Lock = Weapon_Handgun_Flint_Lock_Old + 1;
  static const Weapon_Handgun_Flint_Lock_Superior = Weapon_Handgun_Flint_Lock + 1;
  static const Weapon_Handgun_Blunderbuss = Weapon_Handgun_Flint_Lock_Superior + 1;
  static const Weapon_Handgun_Revolver = Weapon_Handgun_Blunderbuss + 1;
  static const Weapon_Handgun_Glock = Weapon_Handgun_Revolver + 1;
  static const Weapon_Handgun_Desert_Eagle  = Weapon_Handgun_Glock + 1;

  static const Weapon_Rifle_Arquebus = Index_Weapon_Ranged_Rifle + 1;
  static const Weapon_Rifle_Blunderbuss = Weapon_Rifle_Arquebus + 1;
  static const Weapon_Rifle_Musket = Weapon_Rifle_Blunderbuss + 1;
  static const Weapon_Rifle_Jager = Weapon_Rifle_Musket + 1;
  static const Weapon_Rifle_AK_47 = Weapon_Rifle_Jager + 1;
  static const Weapon_Rifle_M4 = Weapon_Rifle_AK_47 + 1;
  static const Weapon_Rifle_Sniper = Weapon_Rifle_M4 + 1;

  static const Weapon_Smg_Mp5 = Index_Weapon_Ranged_Smg + 1;

  static const Weapon_Flamethrower    = Index_Weapon_Special + 1;
  static const Weapon_Special_Bazooka = Index_Weapon_Special + 2;
  static const Weapon_Special_Minigun = Index_Weapon_Special + 3;

  static const Weapon_Ranged_Shotgun = Index_Weapon_Ranged_Shotgun + 1;

  static const Weapon_Ranged_Bow = Index_Weapon_Ranged_Bow + 1;
  static const Weapon_Ranged_Bow_Long = Weapon_Ranged_Bow + 1;
  static const Weapon_Ranged_Crossbow = Weapon_Ranged_Bow_Long + 1;


  static const Recipes = <int, List<int>> {
    Consumables_Apple: const [
      0005, Resource_Gold,
    ],
    Consumables_Meat: const [
     0010, Resource_Gold,
    ],
    Weapon_Handgun_Flint_Lock: const [
      0001, Weapon_Handgun_Flint_Lock_Old,
      0005, Resource_Scrap_Metal,
      0005, Resource_Gold,
    ],
    Weapon_Handgun_Flint_Lock_Superior: const [
      0002, Weapon_Handgun_Flint_Lock,
      0010, Resource_Scrap_Metal,
      0010, Resource_Gold,
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
    Weapon_Rifle_Arquebus: const [
      0002, Weapon_Handgun_Flint_Lock,
      0400, Resource_Scrap_Metal,
      0300, Resource_Gold,
    ],
    Weapon_Rifle_Musket: const [
      0002, Weapon_Rifle_Arquebus,
      0400, Resource_Scrap_Metal,
      0300, Resource_Gold,
    ],
    Weapon_Rifle_Jager: const [
      0300, Weapon_Rifle_Musket,
      0400, Resource_Scrap_Metal,
      0300, Resource_Gold,
    ],
  };

  static bool isTypeEmpty(int value) => value == Empty;
  static bool isNotTypeEmpty(int value) => value != Empty;

  static bool isPersistable(int value) =>
      isTypeEnvironment(value);

  static bool isCollidable(int value) =>
      value == ItemType.GameObjects_Barrel_Purple     ||
      value == ItemType.GameObjects_Barrel_Explosive  ||
      value == ItemType.GameObjects_Barrel_Flaming    ||
      value == ItemType.GameObjects_Barrel            ||
      value == ItemType.GameObjects_Tavern_Sign        ;

  static bool isPhysical(int value) =>
    value == ItemType.GameObjects_Barrel_Purple     ||
    value == ItemType.GameObjects_Barrel_Explosive  ||
    value == ItemType.GameObjects_Barrel_Flaming    ||
    value == ItemType.GameObjects_Barrel            ||
    value == ItemType.GameObjects_Tavern_Sign        ;

  static bool applyGravity(int value) =>
    value == ItemType.GameObjects_Barrel_Purple     ||
    value == ItemType.GameObjects_Barrel_Explosive  ||
    value == ItemType.GameObjects_Barrel_Flaming    ||
    value == ItemType.GameObjects_Barrel             ;

  static bool physicsMoveOnCollision(int value) =>
      value == ItemType.GameObjects_Barrel_Purple     ||
      value == ItemType.GameObjects_Barrel_Explosive  ||
      value == ItemType.GameObjects_Barrel_Flaming    ||
      value == ItemType.GameObjects_Barrel            ||
      value == ItemType.GameObjects_Tavern_Sign        ;

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
      value >= Index_GameObjects && value < Index_Consumables;

  static bool isTypeConsumable(int value) =>
      value >= Index_Consumables && value < Index_Resources;

  static bool isTypeGameObject(int value) =>
      value >= Index_GameObjects && value < Index_Consumables;

  static bool isTypeResource(int value) =>
      value >= Index_Resources && value < Index_Trinkets;

  static bool isTypeTrinket(int value) =>
      value >= Index_Trinkets && value < Index_Heads;

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
      value >= Index_Weapon_Ranged_Handgun &&
      value < Index_Weapon_Ranged_Bow;

  static bool isAutomaticFirearm(int value) =>
      value ==  Weapon_Smg_Mp5      ||
      value ==  Weapon_Rifle_AK_47  ||
      value ==  Weapon_Rifle_M4      ;
  
  static bool isTypeWeaponMelee(int value) =>
      value == ItemType.Empty ||
      (
          value > Index_Weapon_Melee &&
          value < Index_Weapon_Thrown
      );

  static bool isTypeWeaponThrown(int value) =>
      value >= Index_Weapon_Thrown         &&
      value < Index_Weapon_Ranged_Handgun  ;

  static bool isTypeWeaponBow(int value) =>
      value == ItemType.Weapon_Ranged_Bow ||
      value == ItemType.Weapon_Ranged_Bow_Long;

  static bool isTypeWeaponHandgun(int value) =>
      value > Index_Weapon_Ranged_Handgun &&
      value < Index_Weapon_Ranged_Rifle;

  static bool isTypeWeaponRifle(int value) =>
      value > Index_Weapon_Ranged_Rifle &&
      value < Index_Weapon_Ranged_Smg;

  static bool isTypeWeaponShotgun(int value) =>
      value > Index_Weapon_Ranged_Shotgun && value < Index_Weapon_Ranged_Bow;

  static bool isTypeWeaponRanged(int value) =>
      value >= Index_Weapon_Ranged_Handgun && value < Index_Recipe;

  static bool isIndexBelt(int index)=> index >= Belt_1 && index <= Belt_6;

  static bool isTypeRecipe(int value) =>
      value >= Index_Recipe &&
      value < Index_Equipped ;

  static bool isOneHanded(int weaponType) =>
      isTypeWeaponHandgun   (weaponType) ;

  static bool isTwoHanded(int weaponType) =>
      isTypeWeaponRifle       (weaponType) ||
      isTypeWeaponShotgun     (weaponType) ||
      isTypeWeaponBow         (weaponType) ||
      weaponType == Weapon_Special_Bazooka ||
      weaponType == Weapon_Flamethrower    ||
      weaponType == Weapon_Special_Minigun  ;

  static bool isFood(int type) =>
     type == Consumables_Apple ||
     type == Consumables_Meat ;
  
  static bool isCollectable(int type){
    return type >= Index_Consumables;
  }

  static bool isTypeCollectable(int itemType) =>
      isTypeTrinket    (itemType) ||
      isTypeResource   (itemType) ||
      isTypeConsumable (itemType) ||
      isTypeRecipe     (itemType) ||
      isTypeWeapon     (itemType) ||
      isTypeRecipe     (itemType) ||
      isTypeHead       (itemType) ||
      isTypeBody       (itemType) ||
      isTypeLegs       (itemType)  ;


  static int getConsumeType(int itemType) => const {
      Weapon_Thrown_Grenade               : Weapon_Thrown_Grenade,
      Weapon_Handgun_Flint_Lock_Old       : Resource_Gun_Powder,
      Weapon_Handgun_Flint_Lock           : Resource_Gun_Powder,
      Weapon_Handgun_Flint_Lock_Superior  : Resource_Gun_Powder,
      Weapon_Handgun_Glock                : Resource_Round_9mm,
      Weapon_Handgun_Revolver             : Resource_Round_50cal,
      Weapon_Handgun_Desert_Eagle         : Resource_Round_50cal,
      Weapon_Rifle_Arquebus               : Resource_Gun_Powder,
      Weapon_Rifle_Blunderbuss            : Resource_Gun_Powder,
      Weapon_Rifle_Musket                 : Resource_Gun_Powder,
      Weapon_Rifle_Jager                  : Resource_Round_Rifle,
      Weapon_Rifle_M4                     : Resource_Round_Rifle,
      Weapon_Rifle_AK_47                  : Resource_Round_Rifle,
      Weapon_Rifle_Sniper                 : Resource_Round_50cal,
      Weapon_Smg_Mp5                      : Resource_Round_9mm,
      Weapon_Ranged_Shotgun               : Resource_Round_Shotgun,
      Weapon_Ranged_Bow                   : Resource_Arrow,
      Weapon_Flamethrower                 : Resource_Fuel,
      Weapon_Special_Bazooka              : Resource_Rocket,
      Weapon_Special_Minigun              : Resource_Round_Rifle,
  }[itemType] ?? Empty;

  static int getEnergyConsumeAmount(int itemType) => const {
    ItemType.Empty: 1,
    ItemType.Weapon_Melee_Knife: 1,
    ItemType.Weapon_Melee_Axe: 3,
    ItemType.Weapon_Melee_Staff: 3,
    ItemType.Weapon_Melee_Crowbar: 2,
    ItemType.Weapon_Melee_Sword: 3,
    ItemType.Weapon_Melee_Pickaxe: 3,
    ItemType.Weapon_Melee_Hammer: 3,
  }[itemType] ?? 0;

  static int getConsumeAmount(int itemType) => const {
    Weapon_Ranged_Bow: 1,
    Weapon_Handgun_Glock: 1,
    Weapon_Ranged_Shotgun: 3,
    Weapon_Handgun_Flint_Lock_Old: 1,
    Weapon_Handgun_Flint_Lock: 1,
    Weapon_Handgun_Flint_Lock_Superior: 1,
    Weapon_Rifle_Arquebus: 2,
    Weapon_Rifle_Blunderbuss: 2,
    Weapon_Rifle_Musket: 2,
    Weapon_Rifle_Jager: 2,
    Weapon_Rifle_AK_47: 2,
    Weapon_Rifle_M4: 2,
  }[itemType] ?? 0;

  static int getDamage(int value) => const {
      Empty: 1,
      Weapon_Ranged_Shotgun: 2,
      Weapon_Handgun_Flint_Lock_Old: 4,
      Weapon_Handgun_Flint_Lock: 5,
      Weapon_Handgun_Flint_Lock_Superior: 6,
      Weapon_Handgun_Glock: 7,
      Weapon_Handgun_Desert_Eagle: 18,
      Weapon_Handgun_Revolver: 25,
      Weapon_Melee_Sword_Rusty: 3,
      Weapon_Melee_Sword: 3,
      Weapon_Melee_Knife: 3,
      Weapon_Melee_Axe: 3,
      Weapon_Melee_Pickaxe: 3,
      Weapon_Melee_Crowbar: 2,
      Weapon_Ranged_Bow: 1,
      Weapon_Ranged_Bow_Long: 2,
      Weapon_Ranged_Crossbow: 5,
      Weapon_Rifle_Arquebus: 3,
      Weapon_Rifle_Blunderbuss: 4,
      Weapon_Rifle_Musket: 5,
      Weapon_Rifle_Jager: 8,
      Weapon_Rifle_AK_47: 2,
      Weapon_Rifle_M4: 2,
      Weapon_Rifle_Sniper: 50,
      Weapon_Smg_Mp5: 1,
      Trinket_Ring_of_Damage: 1,
      Weapon_Flamethrower: 10,
      Weapon_Special_Bazooka: 100,
      Weapon_Special_Minigun: 7,
  }[value] ?? 1;

  static int getEnergy(int value) => const {
    
  }[value] ?? 0;

  static double getAccuracy(int value) => const <int, double> {
     ItemType.Weapon_Rifle_M4: 0.125,
  }[value] ?? 0.25;

  static double getRange(int value) => const <int, double> {
      Empty: 30,
      Weapon_Thrown_Grenade: 300,
      Weapon_Ranged_Shotgun: 250,
      Weapon_Handgun_Flint_Lock_Old: 350,
      Weapon_Handgun_Flint_Lock: 355,
      Weapon_Handgun_Flint_Lock_Superior: 360,
      Weapon_Handgun_Glock: 350,
      Weapon_Handgun_Desert_Eagle: 350,
      Weapon_Handgun_Revolver: 400,
      Weapon_Ranged_Bow: 300,
      Weapon_Ranged_Bow_Long: 350,
      Weapon_Ranged_Crossbow: 400,
      Weapon_Melee_Sword: 65,
      Weapon_Melee_Knife: 40,
      Weapon_Melee_Axe: 55,
      Weapon_Melee_Hammer: 55,
      Weapon_Melee_Crowbar: 50,
      Weapon_Melee_Pickaxe: 45,
      Weapon_Melee_Staff: 40,
      Weapon_Rifle_Arquebus: 400,
      Weapon_Rifle_Blunderbuss: 400,
      Weapon_Rifle_Musket: 420,
      Weapon_Rifle_Jager: 440,
      Weapon_Rifle_AK_47: 400,
      Weapon_Rifle_M4: 420,
      Weapon_Rifle_Sniper: 750,
      Weapon_Smg_Mp5: 270,
      Weapon_Flamethrower: 150,
      Weapon_Special_Bazooka: 350,
      Weapon_Special_Minigun: 400,
  }[value] ?? 0;

  static int getCooldown(int value) => const {
      Empty: 40,
      Weapon_Thrown_Grenade: 40,
      Weapon_Ranged_Shotgun: 40,
      Weapon_Handgun_Flint_Lock_Old: 50,
      Weapon_Handgun_Flint_Lock: 45,
      Weapon_Handgun_Flint_Lock_Superior: 40,
      Weapon_Handgun_Glock: 20,
      Weapon_Handgun_Revolver: 40,
      Weapon_Handgun_Desert_Eagle: 30,
      Weapon_Melee_Sword: 30,
      Weapon_Melee_Knife: 25,
      Weapon_Melee_Axe: 35,
      Weapon_Melee_Hammer: 40,
      Weapon_Melee_Crowbar: 40,
      Weapon_Melee_Pickaxe: 40,
      Weapon_Melee_Staff: 40,
      Weapon_Ranged_Bow: 50,
      Weapon_Ranged_Bow_Long: 50,
      Weapon_Ranged_Crossbow: 50,
      Weapon_Rifle_Arquebus: 60,
      Weapon_Rifle_Blunderbuss: 80,
      Weapon_Rifle_Musket: 55,
      Weapon_Rifle_Jager: 50,
      Weapon_Rifle_AK_47: 5,
      Weapon_Rifle_M4: 5,
      Weapon_Rifle_Sniper: 75,
      Weapon_Smg_Mp5: 5,
      Weapon_Flamethrower: 2,
      Weapon_Special_Bazooka: 100,
      Weapon_Special_Minigun: 1,
  }[value] ?? 0;

  static String getGroupTypeName(int value) {
    if (isTypeEmpty(value))
      return "Empty";
    if (isTypeTrinket(value))
      return "Trinket";
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
     Base_Health: "Base Health",
     Base_Damage: "Base Damage",
     Base_Energy: "Base Energy",
     Resource_Crystal: "Crystal",
     Resource_Wood: "Wood",
     Resource_Iron: "Iron",
     Resource_Stone: "Stone",
     Resource_Gold: "Gold",
     Resource_Scrap_Metal: "Scrap Metal",
     Resource_Gun_Powder: "Gun-Powder",
     Resource_Round_Shotgun: "Shotgun Rounds",
     Resource_Round_Rifle: "Rifle Rounds",
     Resource_Round_9mm: "9mm Rounds",
     Resource_Round_50cal: "50 Caliber Rounds",
     Resource_Arrow: "Arrow",
     Resource_Rocket: "Rocket",
     Trinket_Ring_of_Damage: "Ring of Damage",
     Trinket_Ring_of_Health: "Ring of Health",
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
     Legs_Blue: "Blue Pants",
     Legs_White: "White Pants",
     Legs_Red: "Red Trousers",
     Weapon_Melee_Sword: "Sword",
     Weapon_Melee_Knife: "Knife",
     Weapon_Melee_Staff: "Staff",
     Weapon_Melee_Axe: "Axe",
     Weapon_Melee_Pickaxe: "Pickaxe",
     Weapon_Melee_Hammer: "Hammer",
     Weapon_Melee_Crowbar: "Crowbar",
     Weapon_Handgun_Flint_Lock_Old: "Old Flint Lock Pistol",
     Weapon_Handgun_Flint_Lock: "Flint Lock Pistol",
     Weapon_Handgun_Flint_Lock_Superior: "Superior Flint Lock Pistol",
     Weapon_Handgun_Blunderbuss: "Blunderbuss Pistol",
     Weapon_Handgun_Glock: "Glock 22",
     Weapon_Handgun_Revolver: "Revolver",
     Weapon_Handgun_Desert_Eagle: "Desert Eagle",
     Weapon_Ranged_Shotgun: "Shotgun",
     Weapon_Rifle_Arquebus: "Arquebus",
     Weapon_Rifle_Blunderbuss: "Blunderbuss",
     Weapon_Rifle_Jager: "Jager Rifle",
     Weapon_Rifle_Musket: "Musket",
     Weapon_Rifle_AK_47: "AK-47",
     Weapon_Rifle_M4: "M4 Assault Rifle",
     Weapon_Rifle_Sniper: "Sniper Rifle",
     Weapon_Smg_Mp5: "Mp5",
     Weapon_Flamethrower: "Flamethrower",
     Weapon_Special_Bazooka: "Bazooka",
     Weapon_Special_Minigun: "Minigun",
     Weapon_Ranged_Bow: "Bow",
     Consumables_Apple: "Apple",
     Consumables_Meat: "Meat",
     Consumables_Potion_Red: "Health Potion",
     Consumables_Potion_Blue: "Energy Potion",
     Weapon_Thrown_Grenade: "Grenade",
     GameObjects_Crystal: "Crystal",
     GameObjects_Crystal_Small_Blue: "Crystal Small Blue",
     GameObjects_Barrel: "Wooden Barrel",
     GameObjects_Barrel_Explosive: "Explosive Barrel",
     GameObjects_Barrel_Purple: "Purple Barrel",
     GameObjects_Barrel_Flaming: "Flaming Barrel",
  }[value] ?? "item-type-unknown($value)";

  static int getMaxQuantity(int itemType) => const {
    Resource_Fuel         : 500,
    Resource_Round_50cal  : 20,
    Resource_Round_Shotgun: 50,
    Resource_Round_Rifle  : 200,
    Resource_Round_9mm    : 100,
    Resource_Scrap_Metal  : 100,
    Resource_Gold         : 100,
    Resource_Gun_Powder   : 100,
    Resource_Arrow        : 100,
    Resource_Rocket       : 8,
    Consumables_Apple     : 010,
    Consumables_Meat      : 010,
    Consumables_Potion_Red: 013,
    Weapon_Handgun_Flint_Lock_Old       : 01,
    Weapon_Handgun_Flint_Lock           : 01,
    Weapon_Handgun_Flint_Lock_Superior  : 01,
    Weapon_Handgun_Glock                : 15,
    Weapon_Handgun_Revolver             : 05,
    Weapon_Handgun_Desert_Eagle         : 07,
    Weapon_Rifle_M4                     : 35,
    Weapon_Rifle_AK_47                  : 35,
    Weapon_Rifle_Jager                  : 04,
    Weapon_Rifle_Musket                 : 01,
    Weapon_Rifle_Sniper                 : 5,
    Weapon_Smg_Mp5                      : 25,
    Weapon_Ranged_Shotgun               : 04,
    Weapon_Thrown_Grenade               : 05,
    Weapon_Flamethrower                 : 200,
    Weapon_Special_Bazooka              : 01,
    Weapon_Special_Minigun              : 1000,
  }[itemType]            ?? 001;

  static int getHealAmount(int itemType) => const {
    Consumables_Apple       : 010,
    Consumables_Meat        : 010,
    Consumables_Potion_Red  : 100,
  }[itemType] ??              000;

  static int getReplenishEnergy(int itemType) => const {
    Consumables_Potion_Blue : 100,
  }[itemType] ??        00;

  static int getMaxHealth(int itemType) => const {
    Trinket_Ring_of_Health  : 05,
    Head_Steel_Helm         : 10,
    Head_Rogues_Hood        : 05,
    Head_Wizards_Hat        : 03,
    Head_Swat               : 15,
    Head_Blonde             : 08,
    Body_Swat               : 40,
    Body_Tunic_Padded   : 50,
    Body_Shirt_Blue     : 10,
    Body_Shirt_Cyan     : 15,
    Legs_Blue           : 10,
    Legs_Brown          : 15,
    Legs_Red            : 20,
    Legs_White          : 25,
    Legs_Green          : 30,
  }[itemType] ??          00;

  static bool hasCapacity(int itemType){
    return getMaxQuantity(itemType) > 0;
  }

  static double getScopeDistance(int itemType){
    return const <int, double> {
        Weapon_Rifle_Arquebus: 1.25,
        Weapon_Rifle_Blunderbuss: 1.33,
        Weapon_Rifle_Musket: 1.5,
        Weapon_Rifle_AK_47: 1.33,
        Weapon_Rifle_Sniper: 3.0,
    }[itemType] ?? 1.0;
  }

  static const HeadTypes = [
      Head_Swat,
      // Head_Blonde,
      Head_Wizards_Hat,
      Head_Rogues_Hood,
      Head_Steel_Helm,
  ];


  static const BodyTypes = [
     Body_Swat,
     Body_Tunic_Padded,
     Body_Shirt_Blue,
     Body_Shirt_Cyan,
  ];

  static const LegTypes = [
     Legs_Swat,
     Legs_Green,
     Legs_White,
     Legs_Red,
     Legs_Brown,
     Legs_Blue,
  ];
  
  static const GameObjectTypes = [
     GameObjects_Barrel,
     GameObjects_Barrel_Explosive,
     GameObjects_Barrel_Purple,
     GameObjects_Barrel_Flaming,
     GameObjects_Tavern_Sign,
     GameObjects_Crystal_Small_Blue,
     GameObjects_Crystal_Small_Red,
  ];

  static bool isTypeBarrel(int type)=> const [
      GameObjects_Barrel,
      GameObjects_Barrel_Explosive,
      GameObjects_Barrel_Purple,
      GameObjects_Barrel_Flaming,
  ].contains(type);
}


