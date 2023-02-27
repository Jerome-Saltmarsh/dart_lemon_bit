
import 'enums/item_group.dart';

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
  static const Index_Weapon                 = 40000;
  static const Index_Weapon_Melee           = 40001;
  static const Index_Weapon_Thrown          = 42500;
  static const Index_Weapon_Ranged          = 45000;
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
  static const GameObjects_Barrel_Explosive     = Index_GameObjects + 18;
  static const GameObjects_Barrel_Purple        = Index_GameObjects + 19;
  static const GameObjects_Barrel_Flaming       = Index_GameObjects + 20;
  static const GameObjects_Toilet               = Index_GameObjects + 21;
  static const GameObjects_Crate_Wooden         = Index_GameObjects + 22;
  static const GameObjects_Desk                 = Index_GameObjects + 23;
  static const GameObjects_Vending_Machine      = Index_GameObjects + 24;
  static const GameObjects_Bed                  = Index_GameObjects + 25;
  static const GameObjects_Firehydrant          = Index_GameObjects + 26;
  static const GameObjects_Aircon_South         = Index_GameObjects + 27;
  static const GameObjects_Sink                 = Index_GameObjects + 28;
  static const GameObjects_Chair                = Index_GameObjects + 29;
  static const GameObjects_Washing_Machine      = Index_GameObjects + 30;
  static const GameObjects_Car_Tire             = Index_GameObjects + 31;
  static const GameObjects_Van                  = Index_GameObjects + 32;
  static const GameObjects_Computer             = Index_GameObjects + 33;
  static const GameObjects_Neon_Sign_01         = Index_GameObjects + 34;
  static const GameObjects_Neon_Sign_02         = Index_GameObjects + 35;
  static const GameObjects_Vending_Upgrades     = Index_GameObjects + 36;
  static const GameObjects_Pipe_Vertical        = Index_GameObjects + 37;

  static const Resource_Wood = Index_Resources + 5;
  static const Resource_Stone = Index_Resources + 6;
  static const Resource_Crystal = Index_Resources + 7;
  static const Resource_Iron = Index_Resources + 8;
  static const Resource_Scrap_Metal = Index_Resources + 9;
  static const Resource_Gold = Index_Resources + 10;
  static const Resource_Credit = Index_Resources + 11;
  static const Resource_Gun_Powder = Index_Resources + 12;
  static const Resource_Arrow = Index_Resources + 13;
  static const Resource_Round_9mm = Index_Resources + 14;
  static const Resource_Round_50cal = Index_Resources + 15;
  static const Resource_Round_Rifle = Index_Resources + 16;
  static const Resource_Round_Shotgun = Index_Resources + 17;
  static const Resource_Fuel = Index_Resources + 18;
  static const Resource_Rocket = Index_Resources + 19;

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

  static const Weapon_Melee_Staff         = Index_Weapon_Melee + 01;
  static const Weapon_Melee_Sword         = Index_Weapon_Melee + 02;
  static const Weapon_Melee_Crowbar       = Index_Weapon_Melee + 03;
  static const Weapon_Melee_Pickaxe       = Index_Weapon_Melee + 04;
  static const Weapon_Melee_Axe           = Index_Weapon_Melee + 05;
  static const Weapon_Melee_Hammer        = Index_Weapon_Melee + 06;
  static const Weapon_Melee_Knife         = Index_Weapon_Melee + 07;

  static const Weapon_Thrown_Pike         = Index_Weapon_Thrown + 01;
  static const Weapon_Thrown_Grenade      = Index_Weapon_Thrown + 02;
  static const Weapon_Thrown_Molotov      = Index_Weapon_Thrown + 03;

  static const Weapon_Ranged_Pistol       = Index_Weapon_Ranged + 01;
  static const Weapon_Ranged_Handgun      = Index_Weapon_Ranged + 02;
  static const Weapon_Ranged_Revolver     = Index_Weapon_Ranged + 03;
  static const Weapon_Ranged_Desert_Eagle = Index_Weapon_Ranged + 04;
  static const Weapon_Ranged_Musket       = Index_Weapon_Ranged + 05;
  static const Weapon_Ranged_Rifle        = Index_Weapon_Ranged + 06;
  static const Weapon_Ranged_Machine_Gun  = Index_Weapon_Ranged + 07;
  static const Weapon_Ranged_Sniper_Rifle = Index_Weapon_Ranged + 09;
  static const Weapon_Ranged_Smg          = Index_Weapon_Ranged + 10;
  static const Weapon_Ranged_Flamethrower = Index_Weapon_Ranged + 11;
  static const Weapon_Ranged_Bazooka      = Index_Weapon_Ranged + 12;
  static const Weapon_Ranged_Minigun      = Index_Weapon_Ranged + 13;
  static const Weapon_Ranged_Shotgun      = Index_Weapon_Ranged + 14;
  static const Weapon_Ranged_Bow          = Index_Weapon_Ranged + 15;
  static const Weapon_Ranged_Crossbow     = Index_Weapon_Ranged + 16;
  static const Weapon_Ranged_Plasma_Rifle = Index_Weapon_Ranged + 17;

  static const Recipes = <int, List<int>> {
    Consumables_Apple: const [
      0003, Resource_Credit,
    ],
    Consumables_Meat: const [
     0006, Resource_Credit,
    ],
    Weapon_Ranged_Pistol: const [
      0010, Resource_Credit,
    ],
    Weapon_Ranged_Revolver: const [
      0050, Resource_Credit,
    ],
    Weapon_Ranged_Handgun: const [
      0050, Resource_Credit,
    ],
    Weapon_Ranged_Musket: const [
      0050, Resource_Credit,
    ],
    Weapon_Ranged_Rifle: const [
      0050, Resource_Credit,
    ],
  };

  static bool isTypeEmpty(int value) => value == Empty;
  static bool isNotTypeEmpty(int value) => value != Empty;
  static bool isPersistable(int value) => isTypeEnvironment(value);


  static double getRadius(int value) => const <int, double> {
    GameObjects_Vending_Machine: 25,
    GameObjects_Bed: 25,
    GameObjects_Car: 25,
    GameObjects_Van: 25,
    GameObjects_Crate_Wooden: 18,
    GameObjects_Barrel_Purple: 18,
    GameObjects_Barrel_Flaming: 18,
    GameObjects_Barrel_Explosive: 18,
    GameObjects_Sink: 10,
    GameObjects_Bottle: 4,
    GameObjects_Pipe_Vertical: 5,
  }[value] ?? 15;

  static bool isStrikable(int value) =>
      value == GameObjects_Barrel_Purple     ||
      value == GameObjects_Barrel_Explosive  ||
      value == GameObjects_Barrel_Flaming    ||
      value == GameObjects_Barrel            ||
      value == GameObjects_Crate_Wooden      ||
      value == GameObjects_Desk              ||
      value == GameObjects_Bed               ||
      value == GameObjects_Vending_Machine   ||
      value == GameObjects_Toilet            ||
      value == GameObjects_Firehydrant       ||
      value == GameObjects_Car               ||
      value == GameObjects_Tavern_Sign        ;

  static bool isFixed(int value) => const [
    GameObjects_Vending_Machine,
    GameObjects_Car,
    GameObjects_Firehydrant,
    GameObjects_Bed,
    GameObjects_Desk,
    GameObjects_Toilet,
    GameObjects_Aircon_South,
    GameObjects_Sink,
    GameObjects_Washing_Machine,
    GameObjects_Van,
    GameObjects_Computer,
    GameObjects_Neon_Sign_01,
    GameObjects_Neon_Sign_02,
    GameObjects_Vending_Upgrades,
    GameObjects_Pipe_Vertical,
  ].contains(value);

  static bool isInteractable(int value) => const [
    GameObjects_Vending_Machine,
    GameObjects_Vending_Upgrades,
  ].contains(value);

  static bool isPhysical(int value) => const [
        GameObjects_Barrel_Purple,
        GameObjects_Grenade,
        Weapon_Thrown_Grenade,
        GameObjects_Barrel_Explosive,
        GameObjects_Barrel_Flaming,
        GameObjects_Barrel,
        GameObjects_Crate_Wooden,
        GameObjects_Desk,
        GameObjects_Vending_Machine,
        GameObjects_Bed,
        GameObjects_Toilet,
        GameObjects_Firehydrant,
        GameObjects_Car,
        GameObjects_Van,
        GameObjects_Aircon_South,
        GameObjects_Tavern_Sign,
        GameObjects_Sink,
        GameObjects_Chair,
        GameObjects_Washing_Machine,
        GameObjects_Vending_Upgrades,
        GameObjects_Pipe_Vertical,
      ].contains(value);

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

  static bool isTypeWeaponFirearm(int value) => const [
    Weapon_Ranged_Pistol,
    Weapon_Ranged_Handgun,
    Weapon_Ranged_Minigun,
    Weapon_Ranged_Musket,
    Weapon_Ranged_Rifle,
    Weapon_Ranged_Machine_Gun,
    Weapon_Ranged_Sniper_Rifle,
    Weapon_Ranged_Flamethrower,
    Weapon_Ranged_Smg,
    Weapon_Ranged_Bazooka,
    Weapon_Ranged_Revolver,
    Weapon_Ranged_Shotgun,
    Weapon_Ranged_Desert_Eagle,
  ].contains(value);

  static bool isAutomaticFirearm(int value) =>
      value ==  Weapon_Ranged_Smg      ||
      value ==  Weapon_Ranged_Minigun  ||
      value ==  Weapon_Ranged_Machine_Gun;

  static bool isTypeWeaponMelee(int value) =>
      value == Empty ||
      (
          value > Index_Weapon_Melee &&
          value < Index_Weapon_Thrown
      );

  static bool isTypeWeaponThrown(int value) =>
      value >= Index_Weapon_Thrown         &&
      value < Index_Weapon_Ranged  ;

  static bool isTypeWeaponBow(int value) =>
      value == Weapon_Ranged_Bow;

  static bool isTypeWeaponHandgun(int value) => const <int> [
      Weapon_Ranged_Desert_Eagle,
      Weapon_Ranged_Revolver,
      Weapon_Ranged_Handgun,
      Weapon_Ranged_Pistol,
  ].contains(value);

  static bool isTypeWeaponRifle(int value) => const <int> [
      Weapon_Ranged_Sniper_Rifle,
      Weapon_Ranged_Machine_Gun,
      Weapon_Ranged_Rifle,
      Weapon_Ranged_Musket,
  ].contains(value);

  static bool isTypeWeaponRanged(int value) =>
      value >= Index_Weapon_Ranged && value < Index_Recipe;

  static bool isIndexBelt(int index)=> index >= Belt_1 && index <= Belt_6;

  static bool isTypeRecipe(int value) =>
      value >= Index_Recipe &&
      value < Index_Equipped ;

  static bool isOneHanded(int itemType) => const <int> [
    Weapon_Ranged_Pistol,
    Weapon_Ranged_Handgun,
    Weapon_Ranged_Revolver,
    Weapon_Ranged_Desert_Eagle,
    Weapon_Ranged_Smg,
    Weapon_Melee_Knife,
    Weapon_Melee_Crowbar,
  ].contains(itemType);

  static bool isTwoHanded(int itemType) => const <int>[
    Weapon_Ranged_Musket,
    Weapon_Ranged_Rifle,
    Weapon_Ranged_Machine_Gun,
    Weapon_Ranged_Sniper_Rifle,
    Weapon_Ranged_Shotgun,
    Weapon_Ranged_Bazooka,
    Weapon_Ranged_Flamethrower,
    Weapon_Ranged_Minigun,
    Weapon_Ranged_Bow,
    Weapon_Melee_Axe,
    Weapon_Melee_Hammer,
    Weapon_Melee_Pickaxe,
    Weapon_Melee_Staff,
    Weapon_Melee_Sword,
  ].contains(itemType);

  static bool isFood(int type) =>
     type == Consumables_Apple ||
     type == Consumables_Meat ;
  
  static bool isCollectable(int type){
    return type >= Index_Consumables;
  }

  static bool isTypeItem(int itemType) =>
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
      Weapon_Ranged_Pistol           : Resource_Gun_Powder,
      Weapon_Ranged_Handgun                : Resource_Round_9mm,
      Weapon_Ranged_Revolver             : Resource_Round_50cal,
      Weapon_Ranged_Desert_Eagle         : Resource_Round_50cal,
      Weapon_Ranged_Musket                 : Resource_Gun_Powder,
      Weapon_Ranged_Rifle                  : Resource_Round_Rifle,
      Weapon_Ranged_Machine_Gun                  : Resource_Round_Rifle,
      Weapon_Ranged_Sniper_Rifle                 : Resource_Round_50cal,
      Weapon_Ranged_Smg                      : Resource_Round_9mm,
      Weapon_Ranged_Shotgun               : Resource_Round_Shotgun,
      Weapon_Ranged_Bow                   : Resource_Arrow,
      Weapon_Ranged_Flamethrower                 : Resource_Fuel,
      Weapon_Ranged_Bazooka              : Resource_Rocket,
      Weapon_Ranged_Minigun              : Resource_Round_Rifle,
  }[itemType] ?? Empty;

  static int getEnergyConsumeAmount(int itemType) => const {
    Empty: 1,
    Weapon_Melee_Knife: 1,
    Weapon_Melee_Axe: 3,
    Weapon_Melee_Staff: 3,
    Weapon_Melee_Crowbar: 2,
    Weapon_Melee_Sword: 3,
    Weapon_Melee_Pickaxe: 3,
    Weapon_Melee_Hammer: 3,
  }[itemType] ?? 0;

  static int getEnergyConsumeAmountMelee(int itemType) => const {
    Empty: 1,
    Weapon_Melee_Knife: 1,
    Weapon_Melee_Axe: 3,
    Weapon_Melee_Staff: 3,
    Weapon_Melee_Crowbar: 2,
    Weapon_Melee_Sword: 3,
    Weapon_Melee_Pickaxe: 3,
    Weapon_Melee_Hammer: 3,
  }[itemType] ?? 1;


  static int getConsumeAmount(int itemType) => const {
    Weapon_Ranged_Bow: 1,
    Weapon_Ranged_Handgun: 1,
    Weapon_Ranged_Shotgun: 3,
    Weapon_Ranged_Pistol: 1,
    Weapon_Ranged_Musket: 2,
    Weapon_Ranged_Rifle: 2,
    Weapon_Ranged_Machine_Gun: 2,
  }[itemType] ?? 0;

  static int getEnergy(int value) => const {
    
  }[value] ?? 0;

  static double getAccuracy(int value) => const <int, double> {

  }[value] ?? 0.25;

  static double getRangeMelee(int value) => const <int, double> {
    Weapon_Ranged_Shotgun: 50,
  }[value] ?? 50;

  static double getRange(int value) => const <int, double> {
      Empty: 30,
      Weapon_Thrown_Grenade: 300,
      Weapon_Ranged_Shotgun: 250,
      Weapon_Ranged_Pistol: 355,
      Weapon_Ranged_Handgun: 350,
      Weapon_Ranged_Desert_Eagle: 350,
      Weapon_Ranged_Revolver: 400,
      Weapon_Ranged_Bow: 300,
      Weapon_Ranged_Crossbow: 400,
      Weapon_Melee_Sword: 65,
      Weapon_Melee_Knife: 40,
      Weapon_Melee_Axe: 55,
      Weapon_Melee_Hammer: 55,
      Weapon_Melee_Crowbar: 50,
      Weapon_Melee_Pickaxe: 45,
      Weapon_Melee_Staff: 40,
      Weapon_Ranged_Musket: 420,
      Weapon_Ranged_Rifle: 440,
      Weapon_Ranged_Machine_Gun: 400,
      Weapon_Ranged_Sniper_Rifle: 750,
      Weapon_Ranged_Smg: 270,
      Weapon_Ranged_Flamethrower: 150,
      Weapon_Ranged_Bazooka: 350,
      Weapon_Ranged_Minigun: 400,
  }[value] ?? 0;

  static int getCooldown(int value) => const {
      Empty: 40,
      Weapon_Thrown_Grenade: 40,
      Weapon_Ranged_Shotgun: 40,
      Weapon_Ranged_Pistol: 45,
      Weapon_Ranged_Handgun: 20,
      Weapon_Ranged_Revolver: 40,
      Weapon_Ranged_Desert_Eagle: 30,
      Weapon_Melee_Sword: 30,
      Weapon_Melee_Knife: 25,
      Weapon_Melee_Axe: 35,
      Weapon_Melee_Hammer: 40,
      Weapon_Melee_Crowbar: 40,
      Weapon_Melee_Pickaxe: 40,
      Weapon_Melee_Staff: 40,
      Weapon_Ranged_Bow: 50,
      Weapon_Ranged_Crossbow: 50,
      Weapon_Ranged_Musket: 55,
      Weapon_Ranged_Rifle: 50,
      Weapon_Ranged_Machine_Gun: 5,
      Weapon_Ranged_Sniper_Rifle: 75,
      Weapon_Ranged_Smg: 5,
      Weapon_Ranged_Flamethrower: 2,
      Weapon_Ranged_Bazooka: 100,
      Weapon_Ranged_Minigun: 1,
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

  static bool isBoundaryRadial(int value) => const [
      GameObjects_Toilet,
      GameObjects_Barrel,
      GameObjects_Barrel_Flaming,
  ].contains(value);

  static bool isBoundaryBox(int value) => const [
    GameObjects_Bed,
    GameObjects_Desk,
  ].contains(value);

  static double getBoxWidth(int itemType) {
    return 0.0;
  }

  static double getBoxHeight(int itemType) {
    return 0.0;
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
     Resource_Credit: "Credits",
     Resource_Scrap_Metal: "Scrap Metal",
     Resource_Gun_Powder: "Gun Powder",
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
     Head_Swat: "Tactical Helm",
     Body_Shirt_Cyan: "Cyan Shirt",
     Body_Shirt_Blue: "Blue Shirt",
     Body_Tunic_Padded: "Padded Tunic",
     Body_Swat: "Tactical Vest",
     Legs_Brown: "Brown Trousers",
     Legs_Swat: "Tactical Pants",
     Legs_Green: "Camo Trousers",
     Legs_Blue: "Jeans",
     Legs_White: "White Pants",
     Legs_Red: "Red Trousers",
     Weapon_Melee_Sword: "Sword",
     Weapon_Melee_Knife: "Knife",
     Weapon_Melee_Staff: "Staff",
     Weapon_Melee_Axe: "Axe",
     Weapon_Melee_Pickaxe: "Pickaxe",
     Weapon_Melee_Hammer: "Hammer",
     Weapon_Melee_Crowbar: "Crowbar",
     Weapon_Ranged_Pistol: "Flint Lock Pistol",
     Weapon_Ranged_Handgun: "Handgun",
     Weapon_Ranged_Revolver: "Revolver",
     Weapon_Ranged_Desert_Eagle: "Desert Eagle",
     Weapon_Ranged_Shotgun: "Shotgun",
     Weapon_Ranged_Rifle: "Bolt-Action Rifle",
     Weapon_Ranged_Musket: "Musket",
     Weapon_Ranged_Machine_Gun: "Machine-Gun",
     Weapon_Ranged_Sniper_Rifle: "Sniper Rifle",
     Weapon_Ranged_Smg: "Smg",
     Weapon_Ranged_Flamethrower: "Flamethrower",
     Weapon_Ranged_Bazooka: "Bazooka",
     Weapon_Ranged_Minigun: "Minigun",
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
     GameObjects_Tavern_Sign: "Tavern Sign",
     GameObjects_Toilet: "Toilet",
     GameObjects_Crate_Wooden: "Wooden Crate",
     GameObjects_Desk: "Wooden Desk",
     GameObjects_Bed: "Bed",
     GameObjects_Car: "Car",
     GameObjects_Vending_Machine: "Vending Machine",
     GameObjects_Firehydrant: "Fire Hydrant",
     GameObjects_Sink: "Sink",
     GameObjects_Chair: "Chair",
     GameObjects_Washing_Machine: "Washing Machine",
     GameObjects_Car_Tire: "Car Tire",
     GameObjects_Bottle: "Bottle",
     GameObjects_Computer: "Computer",
     GameObjects_Neon_Sign_01: "Neon Sign 01",
     GameObjects_Neon_Sign_02: "Neon Sign 02",
    GameObjects_Pipe_Vertical: "Pipe Vertical",
    ItemType.GameObjects_Vending_Upgrades: "Vending Upgrade",
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
    Weapon_Ranged_Pistol           : 01,
    Weapon_Ranged_Handgun                : 15,
    Weapon_Ranged_Revolver             : 05,
    Weapon_Ranged_Desert_Eagle         : 07,
    Weapon_Ranged_Machine_Gun                  : 35,
    Weapon_Ranged_Rifle                  : 04,
    Weapon_Ranged_Musket                 : 01,
    Weapon_Ranged_Sniper_Rifle                 : 5,
    Weapon_Ranged_Smg                      : 25,
    Weapon_Ranged_Shotgun               : 04,
    Weapon_Thrown_Grenade               : 05,
    Weapon_Ranged_Flamethrower                 : 200,
    Weapon_Ranged_Bazooka              : 01,
    Weapon_Ranged_Minigun              : 1000,
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

  static bool hasCapacity(int itemType) =>
    getMaxQuantity(itemType) > 0;

  static double getScopeDistance(int itemType) => const <int, double>{
    Weapon_Ranged_Musket: 1.5,
    Weapon_Ranged_Machine_Gun: 1.33,
    Weapon_Ranged_Sniper_Rifle: 3.0,
  }[itemType] ?? 1.0;

  static const HeadTypes = [
      Head_Swat,
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
     GameObjects_Barrel_Explosive,
     GameObjects_Barrel_Purple,
     GameObjects_Barrel_Flaming,
     GameObjects_Tavern_Sign,
     GameObjects_Crystal_Small_Blue,
     GameObjects_Crystal_Small_Red,
     GameObjects_Toilet,
     GameObjects_Crate_Wooden,
     GameObjects_Desk,
     GameObjects_Vending_Machine,
     GameObjects_Bed,
     GameObjects_Firehydrant,
     GameObjects_Car,
     GameObjects_Aircon_South,
     GameObjects_Sink,
     GameObjects_Chair,
     GameObjects_Washing_Machine,
     GameObjects_Car_Tire,
     GameObjects_Bottle,
     GameObjects_Van,
     GameObjects_Computer,
     GameObjects_Neon_Sign_01,
     GameObjects_Neon_Sign_02,
     GameObjects_Vending_Upgrades,
     GameObjects_Pipe_Vertical,
  ];

  static bool isTypeBarrel(int type)=> const [
      GameObjects_Barrel,
      GameObjects_Barrel_Explosive,
      GameObjects_Barrel_Purple,
      GameObjects_Barrel_Flaming,
  ].contains(type);

  static bool isMaterialMetal(int type)=> const [
    GameObjects_Barrel,
    GameObjects_Barrel_Explosive,
    GameObjects_Barrel_Purple,
    GameObjects_Barrel_Flaming,
    GameObjects_Vending_Machine,
    GameObjects_Firehydrant,
    GameObjects_Car,
    GameObjects_Van,
    GameObjects_Washing_Machine,
  ].contains(type);

  static int getUpgrade(int itemType) {
     return const {
       Weapon_Ranged_Handgun: Weapon_Ranged_Revolver,
     }[itemType] ?? Empty;
  }

  static int getUpgradeCost(int itemType){
    return const {
      Weapon_Ranged_Handgun: 200,
      Weapon_Ranged_Machine_Gun: 300,
    }[itemType] ?? Empty;
  }

  static const Item_Group_Primary_Weapons = [
     Weapon_Ranged_Shotgun,
     Weapon_Ranged_Smg,
     Weapon_Ranged_Sniper_Rifle,
     Weapon_Ranged_Machine_Gun,
     Weapon_Ranged_Rifle,
     Weapon_Ranged_Musket,
     Weapon_Ranged_Minigun,
     Weapon_Ranged_Bazooka,
     Weapon_Ranged_Flamethrower,
  ];

  static const Item_Group_Secondary_Weapons = [
      Weapon_Ranged_Handgun,
      Weapon_Ranged_Revolver,
      Weapon_Ranged_Pistol,
      Weapon_Ranged_Desert_Eagle,
      Weapon_Ranged_Bow,
   ];

  static const Item_Group_Tertiary_Weapons = [
     Empty,
     Weapon_Melee_Crowbar,
     Weapon_Melee_Knife,
     Weapon_Melee_Sword,
     Weapon_Melee_Axe,
     Weapon_Melee_Hammer,
     Weapon_Melee_Pickaxe,
     Weapon_Melee_Staff,
  ];

  static const Item_Group_Head_Types = [
    Head_Wizards_Hat,
    Head_Rogues_Hood,
    Head_Steel_Helm,
    Head_Swat,
  ];

  static const Item_Group_Body_Types = [
    Body_Shirt_Blue,
    Body_Shirt_Cyan,
    Body_Tunic_Padded,
    Body_Swat,
  ];

  static const Item_Group_Leg_Types = [
    Legs_Green,
    Legs_Swat,
    Legs_White,
    Legs_Red,
    Legs_Blue,
    Legs_Brown,
  ];

  static ItemGroup getItemGroup(int itemType) {
     if (Item_Group_Primary_Weapons     .contains(itemType)) 
       return ItemGroup.Primary_Weapon    ;
     if (Item_Group_Secondary_Weapons   .contains(itemType)) 
       return ItemGroup.Secondary_Weapon  ;
     if (Item_Group_Tertiary_Weapons    .contains(itemType)) 
       return ItemGroup.Tertiary_Weapon   ;
     if (Item_Group_Head_Types          .contains(itemType)) 
       return ItemGroup.Head_Type         ;
     if (Item_Group_Body_Types          .contains(itemType)) 
       return ItemGroup.Body_Type         ;
     if (Item_Group_Leg_Types           .contains(itemType)) 
       return ItemGroup.Legs_Type         ;
     if (Collection_Misc                .contains(itemType)) 
       return ItemGroup.Unknown           ;
     
     throw Exception("ItemType.getItemGroup(${getName(itemType)})");
  }

  static double getWeaponLength(int itemType) => const <int, double>{
        Weapon_Ranged_Machine_Gun: 30,
        Weapon_Ranged_Handgun: 20,
  }[itemType] ?? 20;

  static const Collection_Weapons_Rifles = [
     Weapon_Ranged_Musket,
     Weapon_Ranged_Machine_Gun,
     Weapon_Ranged_Sniper_Rifle,
  ];

  static const Collection_Weapons_Handguns = [
    Weapon_Ranged_Pistol,
    Weapon_Ranged_Desert_Eagle,
    Weapon_Ranged_Revolver,
    Weapon_Ranged_Handgun,
  ];

  static const Collection_Weapons_Special = [
    Weapon_Ranged_Bazooka,
    Weapon_Ranged_Minigun,
    Weapon_Ranged_Flamethrower,
  ];

  static const Collection_Weapons_Melee = [
    Weapon_Melee_Axe,
    Weapon_Melee_Sword,
    Weapon_Melee_Crowbar,
    Weapon_Melee_Pickaxe,
    Weapon_Melee_Hammer,
    Weapon_Melee_Staff,
    Weapon_Melee_Knife,
  ];

  static const Collection_Weapons = [
    ...Collection_Weapons_Handguns,
    ...Collection_Weapons_Rifles,
    ...Collection_Weapons_Special,
    ...Collection_Weapons_Melee,
  ];

  static const Collection_Clothing_Head = [
    Head_Swat,
    Head_Steel_Helm,
    Head_Rogues_Hood,
    Head_Wizards_Hat,
  ];

  static const Collection_Clothing_Body = [
    Body_Shirt_Cyan,
    Body_Shirt_Blue,
    Body_Tunic_Padded,
    Body_Swat,
  ];

  static const Collection_Clothing_Legs = [
    Legs_Swat,
    Legs_White,
    Legs_Red,
    Legs_Green,
    Legs_Blue,
    Legs_Brown,
  ];

  static const Collection_Clothing = [
    ...Collection_Clothing_Head,
    ...Collection_Clothing_Body,
    ...Collection_Clothing_Legs,
  ];

  static const Collection_Misc = [
     Weapon_Thrown_Grenade,
     Resource_Round_9mm,
     Resource_Round_Rifle,
     Resource_Round_Shotgun,
  ];

  static const Collection = [
    ...Collection_Clothing,
    ...Collection_Weapons,
    ...Collection_Misc,
  ];
}


