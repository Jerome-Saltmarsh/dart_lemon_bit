import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/amulet_item.dart';

const srcx_weapon_staff = 32.0;
const srcx_weapon_sword = 64.0;
const srcx_weapon_bow = 96.0;
const srcx_consumable = 128.0;
const srcx_helm = 160.0;
const srcx_armor = 192.0;
const srcx_armor_rogue = 256.0;
const srcx_shoes = 224.0;

const _weapons_staff_wooden = [srcx_weapon_staff, 0.0];
const _weapons_sword_short = [srcx_weapon_sword, 0.0];
const _weapons_bow_short = [srcx_weapon_bow, 0.0];
const _helms_pointed_hat_purple = [srcx_helm, 32.0];
const _helms_pointed_hat_black = [srcx_helm, 64.0];
const _helms_leather_cap = [srcx_helm, 0.0];
const _helms_steel_cap = [srcx_helm, 128.0];
const _helms_feather_cap = [srcx_helm, 96.0];
const _helms_full_helm = [srcx_helm, 128.0];
const _helms_circlet = [srcx_helm, 192.0];
const _helms_veil = [srcx_helm, 224.0];
const _armor_tunic = [srcx_armor, 0.0];
const _armor_leather = [srcx_armor, 32.0];
const _armor_chainmail = [srcx_armor, 128.0];
const _armor_platemail = [srcx_armor, 64.0];
const _armor_robe = [srcx_armor, 224.0];
const _armor_cloak = [srcx_armor_rogue, 0.0];
const _armor_mantle = [srcx_armor, 160.0];
const _armor_shroud = [srcx_armor, 192.0];
const _shoes_leather_boots = [srcx_shoes, 0.0];
const _shoes_black_slippers = [srcx_shoes, 64.0];
const _shoes_grieves = [srcx_shoes, 32.0];
const _shoes_treads = [srcx_shoes, 96.0];

const atlasSrcAmuletItem = <AmuletItem, List<double>> {
  AmuletItem.Weapon_Staff_1_Common: _weapons_staff_wooden,
  AmuletItem.Weapon_Staff_1_Of_Fire: _weapons_staff_wooden,
  AmuletItem.Weapon_Staff_1_Of_Frost: _weapons_staff_wooden,
  AmuletItem.Weapon_Staff_1_Legendary: _weapons_staff_wooden,
  AmuletItem.Weapon_Sword_1_Common: _weapons_sword_short,
  AmuletItem.Weapon_Sword_1_Rare: _weapons_sword_short,
  AmuletItem.Weapon_Sword_1_Legendary: _weapons_sword_short,
  AmuletItem.Weapon_Bow_1_Common: _weapons_bow_short,
  AmuletItem.Weapon_Bow_1_Rare: _weapons_bow_short,
  AmuletItem.Weapon_Bow_1_Legendary: _weapons_bow_short,
  AmuletItem.Helm_Warrior_1_Leather_Cap_Common: _helms_leather_cap,
  AmuletItem.Helm_Wizard_1_Pointed_Hat_Purple_Common: _helms_pointed_hat_purple,
  AmuletItem.Helm_Rogue_1_Hood_Common: _helms_feather_cap,
  AmuletItem.Helm_Warrior_2_Steel_Cap_Common: _helms_steel_cap,
  AmuletItem.Helm_Wizard_2_Pointed_Hat_Black_Common: _helms_pointed_hat_black,
  AmuletItem.Helm_Rogue_2_Cape_Common: _helms_feather_cap,
  AmuletItem.Helm_Warrior_3_Full_Helm_Common: _helms_full_helm,
  AmuletItem.Helm_Wizard_3_Circlet_Common: _helms_circlet,
  AmuletItem.Helm_Rogue_3_Veil_Common: _helms_veil,
  AmuletItem.Armor_Neutral_1_Common_Tunic: _armor_tunic,
  AmuletItem.Armor_Warrior_1_Leather_Common: _armor_leather,
  AmuletItem.Armor_Warrior_1_Leather_Rare: _armor_leather,
  AmuletItem.Armor_Warrior_1_Leather_Legendary: _armor_leather,
  AmuletItem.Armor_Warrior_2_Chainmail_Common: _armor_chainmail,
  AmuletItem.Armor_Warrior_2_Chainmail_Rare: _armor_chainmail,
  AmuletItem.Armor_Warrior_2_Chainmail_Legendary: _armor_chainmail,
  AmuletItem.Armor_Warrior_3_Platemail_Common: _armor_platemail,
  AmuletItem.Armor_Warrior_3_Platemail_Rare: _armor_platemail,
  AmuletItem.Armor_Warrior_3_Platemail_Legendary: _armor_platemail,
  AmuletItem.Armor_Wizard_1_Robe_Common: _armor_robe,
  AmuletItem.Armor_Wizard_1_Robe_Rare: _armor_robe,
  AmuletItem.Armor_Wizard_1_Robe_Legendary: _armor_robe,
  AmuletItem.Armor_Rogue_1_Cloak_Common: _armor_cloak,
  AmuletItem.Armor_Rogue_1_Cloak_Rare: _armor_cloak,
  AmuletItem.Armor_Rogue_1_Cloak_Legendary: _armor_cloak,
  AmuletItem.Armor_Rogue_2_Mantle_Common: _armor_mantle,
  AmuletItem.Armor_Rogue_2_Mantle_Rare: _armor_mantle,
  AmuletItem.Armor_Rogue_2_Mantle_Legendary: _armor_mantle,
  AmuletItem.Armor_Rogue_3_Shroud_Common: _armor_shroud,
  AmuletItem.Armor_Rogue_3_Shroud_Rare: _armor_shroud,
  AmuletItem.Armor_Rogue_3_Shroud_Legendary: _armor_shroud,
  AmuletItem.Shoes_Warrior_1_Leather_Boots_Common: _shoes_leather_boots,
  AmuletItem.Shoes_Wizard_1_Black_Slippers_Common: _shoes_black_slippers,
  AmuletItem.Shoes_Rogue_1_Treads_Common: _shoes_treads,
  AmuletItem.Shoes_Warrior_2_Grieves_Common: _shoes_grieves,
  AmuletItem.Shoes_Wizard_2_Footwraps_Common: _shoes_grieves,
  AmuletItem.Shoes_Rogue_2_Striders_Common: _shoes_grieves,
  AmuletItem.Shoes_Warrior_3_Sabatons_Common: _shoes_grieves,
  AmuletItem.Shoes_Wizard_3_Soles_Common: _shoes_grieves,
  AmuletItem.Shoes_Rogue_3_Satin_Boots_Common: _shoes_grieves,
  AmuletItem.Consumable_Potion_Health: [srcx_consumable, 32],
  AmuletItem.Consumable_Potion_Magic: [srcx_consumable, 64],
};