import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/instances/gamestream.dart';
import 'package:golden_ratio/constants.dart';

class AtlasItems {
  static const size = 32.0;

  static List<double> getSrc(int type){

     final value = const <int, List<double>> {
         /// srcX, srcY, srcWidth, srcHeight, anchorX, scale
         ItemType.GameObjects_Flag_Red: [224, 20, 32, 32, 0.5, 1],
     }[type];
     if (value == null){
       throw Exception();
     }
     return value;
  }

  static double getSrcX(int itemType) =>
      itemType == ItemType.GameObjects_Barrel_Flaming ? 34.0 * gamestream.animation.animationFrame6 :

      const <int, double> {
        ItemType.GameObjects_Car: 384,
        ItemType.GameObjects_Crystal: 75,
        ItemType.GameObjects_Candle: 23,
        ItemType.GameObjects_Barrel: 11,
        ItemType.GameObjects_Barrel_Explosive: 128,
        ItemType.GameObjects_Barrel_Purple: 128,
        ItemType.GameObjects_Cup: 0,
        ItemType.GameObjects_Tavern_Sign: 40,
        ItemType.GameObjects_Crystal_Small_Red: 35,
        ItemType.GameObjects_Crystal_Small_Blue: 35,
        ItemType.GameObjects_Aircon_South: 224,
        ItemType.GameObjects_Toilet: 309,
        ItemType.GameObjects_Crate_Wooden: 361,
        ItemType.GameObjects_Desk: 410,
        ItemType.GameObjects_Vending_Machine: 0,
        ItemType.GameObjects_Bed: 447,
        ItemType.GameObjects_Sink: 273,
        ItemType.GameObjects_Firehydrant: 162,
        ItemType.GameObjects_Chair: 273,
        ItemType.GameObjects_Washing_Machine: 304,
        ItemType.GameObjects_Car_Tire: 208,
        ItemType.GameObjects_Bottle: 83,
        ItemType.GameObjects_Van: 102,
        ItemType.GameObjects_Computer: 204,
        ItemType.GameObjects_Neon_Sign_01: 254,
        ItemType.GameObjects_Neon_Sign_02: 304,
        ItemType.GameObjects_Vending_Upgrades: 1,
        ItemType.GameObjects_Pipe_Vertical: 181,
        ItemType.GameObjects_Flag_Red: 368,
        ItemType.GameObjects_Flag_Blue: 416,
        ItemType.Resource_Credit: 448,
        ItemType.Trinket_Ring_of_Health: 256,
        ItemType.Trinket_Ring_of_Damage: 288,
        ItemType.Empty: 224,
        ItemType.Buff_Infinite_Ammo: 512,
        ItemType.Buff_Double_Damage: 512,
        ItemType.Buff_Invincible: 512,
        ItemType.Buff_No_Recoil: 480,
        ItemType.Buff_Fast: 480,
        ItemType.Head_Steel_Helm: 128,
        ItemType.Head_Rogues_Hood: 160,
        ItemType.Head_Wizards_Hat: 192,
        ItemType.Head_Swat: 288,
        ItemType.Body_Shirt_Blue: 64,
        ItemType.Body_Shirt_Cyan: 96,
        ItemType.Body_Tunic_Padded: 128,
        ItemType.Body_Swat: 256,
        ItemType.Legs_Blue: 224,
        ItemType.Legs_Brown: 384,
        ItemType.Legs_Swat: 320,
        ItemType.Legs_Red: 352,
        ItemType.Legs_Green: 384,
        ItemType.Legs_White: 384,
        ItemType.Weapon_Melee_Sword: 0,
        ItemType.Weapon_Melee_Knife: 1,
        ItemType.Weapon_Melee_Staff: 32,
        ItemType.Weapon_Melee_Axe: 128,
        ItemType.Weapon_Melee_Pickaxe: 160,
        ItemType.Weapon_Melee_Hammer: 224,
        ItemType.Weapon_Melee_Crowbar: 256,
        ItemType.Weapon_Ranged_Bow: 64,
        ItemType.Weapon_Thrown_Grenade: 7,
        ItemType.Weapon_Ranged_Shotgun: 177,
        ItemType.Weapon_Ranged_Pistol: 288,
        ItemType.Weapon_Ranged_Handgun: 32,
        ItemType.Weapon_Ranged_Desert_Eagle: 32,
        ItemType.Weapon_Ranged_Revolver: 224,
        ItemType.Weapon_Ranged_Rifle: 595,
        ItemType.Weapon_Ranged_Musket: 64,
        ItemType.Weapon_Ranged_Plasma_Rifle: 577,
        ItemType.Weapon_Ranged_Machine_Gun: 704,
        ItemType.Weapon_Ranged_Sniper_Rifle: 406,
        ItemType.Weapon_Ranged_Smg: 783,
        ItemType.Weapon_Ranged_Flamethrower: 177,
        ItemType.Weapon_Ranged_Bazooka: 298,
        ItemType.Weapon_Ranged_Minigun: 1,
        ItemType.Weapon_Ranged_Plasma_Pistol: 417,
        ItemType.Weapon_Ranged_Teleport: 673,
        ItemType.Resource_Wood: 32,
        ItemType.Resource_Stone: 64,
        ItemType.Resource_Crystal: 96,
        ItemType.Resource_Gold: 128,
        ItemType.Resource_Gun_Powder: 160,
        ItemType.Resource_Round_9mm: 416,
        ItemType.Resource_Round_50cal: 416,
        ItemType.Resource_Round_Rifle: 416,
        ItemType.Resource_Round_Shotgun: 416,
        ItemType.Resource_Arrow: 192,
        ItemType.Resource_Rocket: 192,
        ItemType.Consumables_Meat: 224,
        ItemType.Consumables_Apple: 256,
        ItemType.Consumables_Potion_Red: 448,
        ItemType.Consumables_Potion_Blue: 480,
        ItemType.Consumables_Ammo_Box: 113,
        ItemType.Base_Health: 288,
        ItemType.Base_Energy: 288,
        ItemType.Base_Damage: 352,
      }[itemType] ?? 0;

  static double getSrcY(int itemType) =>
      const <int, double>{
        ItemType.GameObjects_Car: 80,
        ItemType.GameObjects_Crystal: 0,
        ItemType.GameObjects_Candle: 131,
        ItemType.GameObjects_Barrel: 0,
        ItemType.GameObjects_Barrel_Explosive: 39,
        ItemType.GameObjects_Barrel_Purple: 103,
        ItemType.GameObjects_Barrel_Flaming: 176,
        ItemType.GameObjects_Cup: 0,
        ItemType.GameObjects_Tavern_Sign: 0,
        ItemType.GameObjects_Crystal_Small_Blue: 119,
        ItemType.GameObjects_Crystal_Small_Red: 151,
        ItemType.GameObjects_Toilet: 0,
        ItemType.GameObjects_Crate_Wooden: 0,
        ItemType.GameObjects_Desk: 0,
        ItemType.GameObjects_Vending_Machine: 256,
        ItemType.GameObjects_Bed: 0,
        ItemType.GameObjects_Firehydrant: 49,
        ItemType.GameObjects_Aircon_South: 64,
        ItemType.GameObjects_Sink: 48,
        ItemType.GameObjects_Chair: 83,
        ItemType.GameObjects_Washing_Machine: 96,
        ItemType.GameObjects_Car_Tire: 146,
        ItemType.GameObjects_Bottle: 81,
        ItemType.GameObjects_Van: 248,
        ItemType.GameObjects_Computer: 206,
        ItemType.GameObjects_Neon_Sign_01: 210,
        ItemType.GameObjects_Neon_Sign_02: 179,
        ItemType.GameObjects_Vending_Upgrades: 329,
        ItemType.GameObjects_Pipe_Vertical: 247,
        ItemType.GameObjects_Flag_Red: 224,
        ItemType.GameObjects_Flag_Blue: 224,
        ItemType.Trinket_Ring_of_Health: 32,
        ItemType.Trinket_Ring_of_Damage: 32,
        ItemType.Weapon_Ranged_Shotgun: 243,
        ItemType.Buff_Infinite_Ammo: 64,
        ItemType.Buff_Double_Damage: 32,
        ItemType.Buff_Invincible: 96,
        ItemType.Buff_No_Recoil: 64,
        ItemType.Buff_Fast: 96,
        ItemType.Head_Swat: 96,
        ItemType.Body_Shirt_Blue: 32,
        ItemType.Body_Shirt_Cyan: 32,
        ItemType.Body_Tunic_Padded: 32,
        ItemType.Body_Swat: 96,
        ItemType.Legs_Blue: 32,
        ItemType.Legs_Swat: 96,
        ItemType.Legs_Red: 96,
        ItemType.Legs_Green: 96,
        ItemType.Legs_White: 64,
        ItemType.Legs_Brown: 128,
        ItemType.Resource_Wood: 64,
        ItemType.Resource_Stone: 64,
        ItemType.Resource_Crystal: 64,
        ItemType.Resource_Gold: 64,
        ItemType.Resource_Credit: 32,
        ItemType.Resource_Gun_Powder: 64,
        ItemType.Resource_Round_9mm: 0,
        ItemType.Resource_Round_Shotgun: 32,
        ItemType.Resource_Round_Rifle: 64,
        ItemType.Resource_Round_50cal: 96,
        ItemType.Resource_Scrap_Metal: 96,
        ItemType.Resource_Rocket: 96,
        ItemType.Resource_Arrow: 64,
        ItemType.Consumables_Meat: 64,
        ItemType.Consumables_Apple: 64,
        ItemType.Weapon_Thrown_Grenade: 176,
        ItemType.Weapon_Melee_Knife: 224,
        ItemType.Weapon_Melee_Staff: 0,
        ItemType.Weapon_Melee_Axe: 128,
        ItemType.Weapon_Melee_Pickaxe: 128,
        ItemType.Weapon_Melee_Hammer: 128,
        ItemType.Weapon_Melee_Crowbar: 128,
        ItemType.Weapon_Ranged_Handgun: 96,
        ItemType.Weapon_Ranged_Revolver: 96,
        ItemType.Weapon_Ranged_Desert_Eagle: 32,
        ItemType.Weapon_Ranged_Rifle: 0,
        ItemType.Weapon_Ranged_Musket: 96,
        ItemType.Weapon_Ranged_Plasma_Rifle: 1,
        ItemType.Weapon_Ranged_Machine_Gun: 236,
        ItemType.Weapon_Ranged_Sniper_Rifle: 161,
        ItemType.Weapon_Ranged_Smg: 85,
        ItemType.Weapon_Ranged_Flamethrower: 161,
        ItemType.Weapon_Ranged_Bazooka: 219,
        ItemType.Weapon_Ranged_Minigun: 130,
        ItemType.Weapon_Ranged_Plasma_Pistol: 208,
        ItemType.Weapon_Ranged_Teleport: 42,
        ItemType.Base_Health: 64,
        ItemType.Base_Energy: 64,
        ItemType.Base_Damage: 64,
        ItemType.Consumables_Potion_Red: 0,
        ItemType.Consumables_Potion_Blue: 0,
        ItemType.Consumables_Ammo_Box: 160,
      }[itemType] ?? 0;

  static double getSrcWidth(int itemType) =>
      const <int, double>{
        ItemType.GameObjects_Car: 115,
        ItemType.GameObjects_Crystal: 22,
        ItemType.GameObjects_Barrel: 28,
        ItemType.GameObjects_Barrel_Explosive: 33,
        ItemType.GameObjects_Barrel_Purple: 33,
        ItemType.GameObjects_Barrel_Flaming: 33,
        ItemType.GameObjects_Crystal_Small_Blue: 10,
        ItemType.GameObjects_Crystal_Small_Red: 10,
        ItemType.GameObjects_Cup: 6,
        ItemType.GameObjects_Tavern_Sign: 19,
        ItemType.GameObjects_Candle: 3,
        ItemType.GameObjects_Toilet: 51,
        ItemType.GameObjects_Crate_Wooden: 48,
        ItemType.GameObjects_Desk: 36,
        ItemType.GameObjects_Vending_Machine: 48,
        ItemType.GameObjects_Bed: 56,
        ItemType.GameObjects_Firehydrant: 53,
        ItemType.GameObjects_Aircon_South: 48,
        ItemType.GameObjects_Sink: 27,
        ItemType.GameObjects_Chair: 24,
        ItemType.GameObjects_Washing_Machine: 48,
        ItemType.GameObjects_Car_Tire: 56,
        ItemType.GameObjects_Bottle: 18,
        ItemType.GameObjects_Van: 78,
        ItemType.GameObjects_Computer: 40,
        ItemType.GameObjects_Neon_Sign_01: 43,
        ItemType.GameObjects_Neon_Sign_02: 21,
        ItemType.GameObjects_Vending_Upgrades: 39,
        ItemType.GameObjects_Pipe_Vertical: 8,
        ItemType.GameObjects_Flag_Red: 32,
        ItemType.GameObjects_Flag_Blue: 32,
        ItemType.Weapon_Ranged_Sniper_Rifle: 121,
        ItemType.Weapon_Ranged_Flamethrower: 114,
        ItemType.Weapon_Ranged_Bazooka: 117,
        ItemType.Weapon_Ranged_Minigun: 35,
        ItemType.Weapon_Ranged_Rifle: 429,
        ItemType.Weapon_Ranged_Smg: 240,
        ItemType.Weapon_Ranged_Plasma_Rifle: 83,
        ItemType.Weapon_Ranged_Machine_Gun: 319,
        ItemType.Weapon_Ranged_Shotgun: 117,
        ItemType.Weapon_Ranged_Plasma_Pistol: 46,
        ItemType.Weapon_Ranged_Teleport: 80,
        ItemType.Weapon_Thrown_Grenade: 38,
        ItemType.Weapon_Melee_Knife: 44,
        ItemType.Consumables_Ammo_Box: 56,
      }[itemType] ?? size;

  static double getSrcHeight(int itemType) => const <int, double>{
    ItemType.GameObjects_Car: 133,
    ItemType.GameObjects_Crystal: 45,
    ItemType.GameObjects_Barrel: 40,
    ItemType.GameObjects_Barrel_Explosive: 63,
    ItemType.GameObjects_Barrel_Purple: 63,
    ItemType.GameObjects_Barrel_Flaming: 70,
    ItemType.GameObjects_Crate_Wooden: 80,
    ItemType.GameObjects_Desk: 59,
    ItemType.GameObjects_Candle: 10,
    ItemType.GameObjects_Cup: 11,
    ItemType.GameObjects_Tavern_Sign: 39,
    ItemType.GameObjects_Firehydrant: 104,
    ItemType.GameObjects_Washing_Machine: 81,
    ItemType.GameObjects_Crystal_Small_Blue: 18,
    ItemType.GameObjects_Crystal_Small_Red: 18,
    ItemType.GameObjects_Toilet: 92,
    ItemType.GameObjects_Vending_Machine: 72,
    ItemType.GameObjects_Car_Tire: 57,
    ItemType.GameObjects_Bottle: 58,
    ItemType.GameObjects_Bed: 78,
    ItemType.GameObjects_Aircon_South: 81,
    ItemType.GameObjects_Sink: 33,
    ItemType.GameObjects_Van: 129,
    ItemType.GameObjects_Chair: 49,
    ItemType.GameObjects_Computer: 68,
    ItemType.GameObjects_Neon_Sign_01: 144,
    ItemType.GameObjects_Neon_Sign_02: 33,
    ItemType.GameObjects_Vending_Upgrades: 94,
    ItemType.GameObjects_Pipe_Vertical: 40,
    ItemType.GameObjects_Flag_Red: 32,
    ItemType.GameObjects_Flag_Blue: 32,
    ItemType.Weapon_Ranged_Sniper_Rifle: 37,
    ItemType.Weapon_Ranged_Bazooka: 52,
    ItemType.Weapon_Ranged_Minigun: 12,
    ItemType.Weapon_Ranged_Rifle: 83,
    ItemType.Weapon_Ranged_Smg: 150,
    ItemType.Weapon_Ranged_Machine_Gun: 93,
    ItemType.Weapon_Ranged_Plasma_Rifle: 53,
    ItemType.Weapon_Ranged_Shotgun: 28,
    ItemType.Weapon_Ranged_Plasma_Pistol: 37,
    ItemType.Weapon_Ranged_Teleport: 42,
    ItemType.Weapon_Ranged_Flamethrower: 66,
    ItemType.Weapon_Thrown_Grenade: 45,
    ItemType.Weapon_Melee_Knife: 10,
    ItemType.Consumables_Ammo_Box: 80,
  }[itemType] ?? size;

  static double getSrcScale(int itemType) => const <int, double> {
    ItemType.GameObjects_Barrel_Explosive: 0.75,
    ItemType.GameObjects_Barrel_Purple: 0.75,
    ItemType.GameObjects_Barrel_Flaming: 0.75,
    ItemType.GameObjects_Toilet: 0.5,
    ItemType.GameObjects_Crate_Wooden: 0.75,
    ItemType.GameObjects_Firehydrant: 0.4,
    ItemType.GameObjects_Car: 0.66,
    ItemType.GameObjects_Aircon_South: 0.6,
    ItemType.GameObjects_Sink: 0.75,
    ItemType.GameObjects_Washing_Machine: 0.75,
    ItemType.GameObjects_Car_Tire: 0.5,
    ItemType.GameObjects_Bottle: 0.4,
    ItemType.GameObjects_Computer: 0.61,
    ItemType.Resource_Credit: goldenRatio_0618,
    ItemType.Weapon_Thrown_Grenade: 0.5,
    ItemType.Consumables_Ammo_Box: goldenRatio_0381,
  }[itemType] ?? 1.0;

  static double getAnchorY(int itemType) => const <int, double> {
    ItemType.GameObjects_Barrel_Explosive: 0.65,
    ItemType.GameObjects_Barrel_Purple: 0.65,
    ItemType.GameObjects_Barrel_Flaming: 0.65,
    ItemType.GameObjects_Crate_Wooden: 0.61,
    ItemType.GameObjects_Vending_Machine: 0.6,
    ItemType.GameObjects_Vending_Upgrades: 0.7,
    ItemType.GameObjects_Firehydrant: 0.66,
    ItemType.GameObjects_Bottle: 0.6,
    ItemType.GameObjects_Van: 0.6,
    ItemType.GameObjects_Pipe_Vertical: 0.9,
  }[itemType] ?? 0.5;
}
