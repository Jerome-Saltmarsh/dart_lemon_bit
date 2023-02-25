import 'package:bleed_server/common/src/item_type.dart';

class GameOptions {
  final bool perks;
  final bool inventory;
  final bool items;

  final Map<int, int> itemDamage;
  final List<int> itemTypes;
  final Map<int, List<int>> itemTypeCost;
  final Map<int, List<int>> itemTypeDamage;

  GameOptions({
    required this.perks,
    required this.inventory,
    required this.items,
    this.itemTypes = ItemType.Collection,
    this.itemDamage = Default_Item_Damage,
    this.itemTypeDamage = Default_ItemType_Damage,
    this.itemTypeCost = Default_ItemType_Cost,
  });

  static const Default_ItemType_Damage = <int, List<int>> {
     ItemType.Weapon_Ranged_Smg: [2, 3, 4, 5, 6],
     ItemType.Weapon_Rifle_M4: [2, 3, 4, 5, 6],
     ItemType.Weapon_Ranged_AK_47: [2, 3, 4, 5, 6],
     ItemType.Weapon_Ranged_Rifle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Sniper_Rifle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Rifle_Musket: [4, 5, 7, 8, 10],
     ItemType.Weapon_Rifle_Blunderbuss: [4, 5, 7, 8, 10],
     ItemType.Weapon_Rifle_Arquebus: [4, 5, 7, 8, 10],

     ItemType.Weapon_Ranged_Bazooka: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Flamethrower: [4, 5, 7, 8, 10],
     ItemType.Weapon_Special_Minigun: [4, 5, 7, 8, 10],

     ItemType.Weapon_Ranged_Glock: [4, 5, 7, 8, 10],
     ItemType.Weapon_Ranged_Revolver: [4, 5, 7, 8, 10],
     ItemType.Weapon_Handgun_Desert_Eagle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Handgun_Flint_Lock: [4, 5, 7, 8, 10],

     ItemType.Weapon_Melee_Hammer: [3, 4, 5, 6, 7],
     ItemType.Weapon_Melee_Pickaxe: [5, 7, 10, 12, 14],
     ItemType.Weapon_Melee_Knife: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Crowbar: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Sword: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Axe: [4, 5, 7, 8, 10],
  };

  static const Default_ItemType_Cost = <int, List<int>> {
     ItemType.Weapon_Ranged_AK_47: [10, 15, 30, 50, 100],
     ItemType.Weapon_Ranged_Rifle: [4, 5, 7, 8, 10],
     ItemType.Weapon_Melee_Hammer: [3, 4, 5, 6, 7],
     ItemType.Weapon_Melee_Pickaxe: [5, 7, 10, 12, 14],
  };

  static const Default_Item_Damage = <int, int> {
    ItemType.Empty: 1,
    ItemType.Weapon_Ranged_Shotgun: 2,
    ItemType.Weapon_Handgun_Flint_Lock_Old: 4,
    ItemType.Weapon_Handgun_Flint_Lock: 5,
    ItemType.Weapon_Handgun_Flint_Lock_Superior: 6,
    ItemType.Weapon_Ranged_Glock: 7,
    ItemType.Weapon_Handgun_Desert_Eagle: 18,
    ItemType.Weapon_Ranged_Revolver: 25,
    ItemType.Weapon_Melee_Sword: 3,
    ItemType.Weapon_Melee_Knife: 3,
    ItemType.Weapon_Melee_Axe: 3,
    ItemType.Weapon_Melee_Pickaxe: 3,
    ItemType.Weapon_Melee_Crowbar: 2,
    ItemType.Weapon_Ranged_Bow: 1,
    ItemType.Weapon_Ranged_Crossbow: 5,
    ItemType.Weapon_Rifle_Arquebus: 3,
    ItemType.Weapon_Rifle_Blunderbuss: 4,
    ItemType.Weapon_Rifle_Musket: 5,
    ItemType.Weapon_Ranged_Rifle: 8,
    ItemType.Weapon_Ranged_AK_47: 2,
    ItemType.Weapon_Rifle_M4: 2,
    ItemType.Weapon_Ranged_Sniper_Rifle: 50,
    ItemType.Weapon_Ranged_Smg: 1,
    ItemType.Trinket_Ring_of_Damage: 1,
    ItemType.Weapon_Ranged_Flamethrower: 10,
    ItemType.Weapon_Ranged_Bazooka: 100,
    ItemType.Weapon_Special_Minigun: 7,
  };
}
