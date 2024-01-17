import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/amulet_item.dart';

const srcx_weapon_staff = 32.0;
const srcx_weapon_sword = 64.0;
const srcx_weapon_bow = 96.0;
const srcx_consumable = 128.0;
const srcx_helm = 160.0;
const srcx_armor = 192.0;
const srcx_shoes = 224.0;

const _helms_pointed_hat_purple = const [srcx_helm, 32.0];
const _helms_pointed_hat_black = const [srcx_helm, 64.0];
const _helms_leather_cap = const [srcx_helm, 0.0];
const _helms_steel_cap = const [srcx_helm, 128.0];
const _helms_steel_helm = const [srcx_helm, 160.0];
const _armor_leather = const [srcx_armor, 32.0];
const _armor_chainmail = const [srcx_armor, 128.0];
const _armor_platemail = const [srcx_armor, 64.0];

const atlasSrcAmuletItem = <AmuletItem, List<double>> {
  AmuletItem.Weapon_Staff_1_5_Common: [srcx_weapon_staff, 0],
  AmuletItem.Weapon_Staff_1_5_Rare: [srcx_weapon_staff, 0],
  AmuletItem.Weapon_Staff_1_5_Legendary: [srcx_weapon_staff, 0],
  AmuletItem.Weapon_Sword_1_5_Common: [srcx_weapon_sword, 0],
  AmuletItem.Weapon_Sword_1_5_Rare: [srcx_weapon_sword, 0],
  AmuletItem.Weapon_Sword_1_5_Legendary: [srcx_weapon_sword, 0],
  AmuletItem.Weapon_Bow_1_5_Common: [srcx_weapon_bow, 0],
  AmuletItem.Weapon_Bow_1_5_Rare: [srcx_weapon_bow, 0],
  AmuletItem.Weapon_Bow_1_5_Legendary: [srcx_weapon_bow, 0],
  AmuletItem.Consumable_Potion_Health: [srcx_consumable, 32],
  AmuletItem.Consumable_Potion_Magic: [srcx_consumable, 64],
  AmuletItem.Helm_Warrior_1_5_Common: _helms_leather_cap,
  AmuletItem.Helm_Wizard_1_5_Common: _helms_pointed_hat_purple,
  AmuletItem.Helm_Rogue_1_5_Common: [srcx_helm, 64],
  AmuletItem.Armor_Neutral_1_5_Common: [srcx_armor, 0],
  AmuletItem.Armor_Rogue_1_5_Common: [srcx_armor, 32],
  AmuletItem.Armor_Rogue_1_5_Rare: [srcx_armor, 32],
  AmuletItem.Armor_Rogue_1_5_Legendary: [srcx_armor, 32],
  AmuletItem.Armor_Warrior_1_5_Common: _armor_leather,
  AmuletItem.Armor_Warrior_1_5_Rare: _armor_chainmail,
  AmuletItem.Armor_Warrior_1_5_Legendary: _armor_platemail,
  AmuletItem.Armor_Wizard_1_5_Common: [srcx_armor, 96],
  AmuletItem.Armor_Wizard_1_5_Rare: [srcx_armor, 96],
  AmuletItem.Armor_Wizard_1_5_Legendary: [srcx_armor, 96],
  AmuletItem.Shoes_Rogue_1_5_Common: [srcx_shoes, 0],
  AmuletItem.Shoes_Warrior_1_5_Common: [srcx_shoes, 32],
  AmuletItem.Shoes_Wizard_1_5_Common: [srcx_shoes, 0],
};