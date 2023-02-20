import 'package:bleed_server/common/src/item_type.dart';

class GameOptions {
  final bool perks;
  final bool inventory;
  final bool items;

  final Map<int, int> itemDamage;

  GameOptions({
    required this.perks,
    required this.inventory,
    required this.items,
    this.itemDamage = Default_Item_Damage,
  });

  static const Default_Item_Damage = <int, int> {
    ItemType.Empty: 1,
    ItemType.Weapon_Ranged_Shotgun: 2,
    ItemType.Weapon_Handgun_Flint_Lock_Old: 4,
    ItemType.Weapon_Handgun_Flint_Lock: 5,
    ItemType.Weapon_Handgun_Flint_Lock_Superior: 6,
    ItemType.Weapon_Handgun_Glock: 7,
    ItemType.Weapon_Handgun_Desert_Eagle: 18,
    ItemType.Weapon_Handgun_Revolver: 25,
    ItemType.Weapon_Melee_Sword_Rusty: 3,
    ItemType.Weapon_Melee_Sword: 3,
    ItemType.Weapon_Melee_Knife: 3,
    ItemType.Weapon_Melee_Axe: 3,
    ItemType.Weapon_Melee_Pickaxe: 3,
    ItemType.Weapon_Melee_Crowbar: 2,
    ItemType.Weapon_Ranged_Bow: 1,
    ItemType.Weapon_Ranged_Bow_Long: 2,
    ItemType.Weapon_Ranged_Crossbow: 5,
    ItemType.Weapon_Rifle_Arquebus: 3,
    ItemType.Weapon_Rifle_Blunderbuss: 4,
    ItemType.Weapon_Rifle_Musket: 5,
    ItemType.Weapon_Rifle_Jager: 8,
    ItemType.Weapon_Rifle_AK_47: 2,
    ItemType.Weapon_Rifle_M4: 2,
    ItemType.Weapon_Rifle_Sniper: 50,
    ItemType.Weapon_Smg_Mp5: 1,
    ItemType.Trinket_Ring_of_Damage: 1,
    ItemType.Weapon_Flamethrower: 10,
    ItemType.Weapon_Special_Bazooka: 100,
    ItemType.Weapon_Special_Minigun: 7,
  };
}
