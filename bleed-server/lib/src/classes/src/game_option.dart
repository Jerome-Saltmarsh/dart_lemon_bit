import 'package:bleed_server/common/src/item_type.dart';

class GameOptions {
  final bool perks;
  final bool inventory;
  final bool items;

  final Map<int, int> itemDamage;
  final List<int> itemTypes;
  final Map<int, List<int>> itemTypeCost;
  final Map<int, List<int>> itemTypeDamage;
  final Map<int, List<int>> itemTypeCapacity;

  GameOptions({
    required this.perks,
    required this.inventory,
    required this.items,
    this.itemTypes = ItemType.Collection,
    this.itemDamage = Default_Item_Damage,
    this.itemTypeDamage = Default_ItemType_Damage,
    this.itemTypeCost = Default_ItemType_Cost,
    this.itemTypeCapacity = Default_ItemType_Capacity,
  });

  static const Default_ItemType_Damage = <int, List<int>> {
     ItemType.Empty: [1, 1, 1, 1, 1],
     ItemType.Weapon_Ranged_Smg: [2, 3, 4, 5, 6],
     ItemType.Weapon_Ranged_Machine_Gun: [2, 3, 4, 5, 6],
     ItemType.Weapon_Ranged_Rifle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Sniper_Rifle: [10, 10, 10, 10, 10],
     ItemType.Weapon_Ranged_Musket: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Bazooka: [10, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Flamethrower: [1, 1, 1, 1, 1],
     ItemType.Weapon_Ranged_Minigun: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Handgun: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Revolver: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Desert_Eagle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Pistol: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Plasma_Pistol: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Plasma_Rifle: [2, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Shotgun: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Hammer: [3, 4, 5, 6, 7],
     ItemType.Weapon_Melee_Pickaxe: [5, 7, 10, 12, 14],
     ItemType.Weapon_Melee_Knife: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Crowbar: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Sword: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Axe: [4, 5, 7, 8, 10],
  };

  static const Default_ItemType_Capacity = <int, List<int>> {
     ItemType.Weapon_Thrown_Grenade: [3, 4, 5, 6, 7],
     ItemType.Weapon_Ranged_Smg: [2, 3, 4, 5, 6],
     ItemType.Weapon_Ranged_Machine_Gun: [2, 3, 4, 5, 6],
     ItemType.Weapon_Ranged_Rifle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Sniper_Rifle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Musket: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Bazooka: [4, 5, 6, 7, 8],
     ItemType.Weapon_Ranged_Flamethrower: [50, 70, 90, 110, 130],
     ItemType.Weapon_Ranged_Minigun: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Handgun: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Revolver: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Desert_Eagle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Pistol: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Plasma_Pistol: [8, 10, 12, 14, 16],
     ItemType.Weapon_Ranged_Plasma_Rifle: [30, 40, 50, 60, 70],
     ItemType.Weapon_Ranged_Shotgun: [4, 6, 8, 10, 12],
     ItemType.Weapon_Melee_Crowbar: [10, 10, 10, 10, 10],
     ItemType.Weapon_Melee_Pickaxe: [10, 10, 10, 10, 10],
  };

  static const Default_ItemType_Cost = <int, List<int>> {
     ItemType.Weapon_Ranged_Plasma_Pistol: [10, 15, 30, 50, 100],
     ItemType.Weapon_Ranged_Plasma_Rifle: [10, 15, 30, 50, 100],
     ItemType.Weapon_Ranged_Machine_Gun: [10, 15, 30, 50, 100],
     ItemType.Weapon_Ranged_Rifle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Bazooka: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Flamethrower: [4, 5, 7, 8, 10],
  };

  static const Default_Item_Damage = <int, int> {
    ItemType.Empty: 1,
    ItemType.Weapon_Ranged_Shotgun: 2,
    ItemType.Weapon_Ranged_Pistol: 5,
    ItemType.Weapon_Ranged_Handgun: 7,
    ItemType.Weapon_Ranged_Desert_Eagle: 18,
    ItemType.Weapon_Ranged_Revolver: 25,
    ItemType.Weapon_Melee_Sword: 3,
    ItemType.Weapon_Melee_Knife: 3,
    ItemType.Weapon_Melee_Axe: 3,
    ItemType.Weapon_Melee_Pickaxe: 3,
    ItemType.Weapon_Melee_Crowbar: 2,
    ItemType.Weapon_Ranged_Bow: 1,
    ItemType.Weapon_Ranged_Crossbow: 5,
    ItemType.Weapon_Ranged_Musket: 5,
    ItemType.Weapon_Ranged_Rifle: 8,
    ItemType.Weapon_Ranged_Machine_Gun: 2,
    ItemType.Weapon_Ranged_Sniper_Rifle: 50,
    ItemType.Weapon_Ranged_Smg: 1,
    ItemType.Weapon_Ranged_Flamethrower: 10,
    ItemType.Weapon_Ranged_Bazooka: 100,
    ItemType.Weapon_Ranged_Minigun: 7,
    ItemType.Trinket_Ring_of_Damage: 1,
  };
}
