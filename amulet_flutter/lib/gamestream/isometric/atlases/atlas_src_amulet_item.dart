import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/amulet_item.dart';

const _weapon_staff = 32.0;
const _weapon_sword = 64.0;
const _weapon_bow = 96.0;
const _consumable = 128.0;
const _helm = 160.0;
const _armor = 192.0;
const _shoes = 224.0;

const atlasSrcAmuletItem = <AmuletItem, List<double>> {
  AmuletItem.Weapon_Staff_1_5_Common: [_weapon_staff, 0],
  AmuletItem.Weapon_Staff_1_5_Rare: [_weapon_staff, 0],
  AmuletItem.Weapon_Staff_1_5_Legendary: [_weapon_staff, 0],
  AmuletItem.Weapon_Sword_1_5_Common: [_weapon_sword, 0],
  AmuletItem.Weapon_Sword_1_5_Rare: [_weapon_sword, 0],
  AmuletItem.Weapon_Sword_1_5_Legendary: [_weapon_sword, 0],
  AmuletItem.Weapon_Bow_1_5_Common: [_weapon_bow, 0],
  AmuletItem.Weapon_Bow_1_5_Rare: [_weapon_bow, 0],
  AmuletItem.Weapon_Bow_1_5_Legendary: [_weapon_bow, 0],
  AmuletItem.Consumable_Potion_Health: [_consumable, 32],
  AmuletItem.Consumable_Potion_Magic: [_consumable, 64],
  AmuletItem.Helm_Warrior_1_5_Common: [_helm, 0],
  AmuletItem.Helm_Wizard_1_5_Common: [_helm, 32],
  AmuletItem.Helm_Rogue_1_5_Common: [_helm, 64],
  AmuletItem.Armor_Neutral_1_5_Common: [_armor, 0],
  AmuletItem.Armor_Rogue_1_5_Common: [_armor, 32],
  AmuletItem.Armor_Rogue_1_5_Rare: [_armor, 32],
  AmuletItem.Armor_Rogue_1_5_Legendary: [_armor, 32],
  AmuletItem.Armor_Warrior_1_5_Common: [_armor, 64],
  AmuletItem.Armor_Warrior_1_5_Rare: [_armor, 64],
  AmuletItem.Armor_Warrior_1_5_Legendary: [_armor, 64],
  AmuletItem.Armor_Wizard_1_5_Common: [_armor, 96],
  AmuletItem.Armor_Wizard_1_5_Rare: [_armor, 96],
  AmuletItem.Armor_Wizard_1_5_Legendary: [_armor, 96],
  AmuletItem.Shoes_Rogue_1_5_Common: [_shoes, 0],
  AmuletItem.Shoes_Warrior_1_5_Common: [_shoes, 32],
  AmuletItem.Shoes_Wizard_1_5_Common: [_shoes, 0],
};