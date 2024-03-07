import 'package:amulet_engine/common/src.dart';

const srcx_weapon_staff = 32.0;
const srcx_weapon_sword = 64.0;
const srcx_weapon_bow = 96.0;
const srcx_consumable = 128.0;
const srcx_helm = 160.0;
const srcx_armor = 192.0;
const srcx_armor_rogue = 256.0;
const srcx_shoes = 224.0;

const _weapons_sword_short = [srcx_weapon_sword, 0.0];
const _weapons_sword_broad = [srcx_weapon_sword, 32.0];
const _weapons_sword_long = [srcx_weapon_sword, 64.0];
const _weapons_sword_giant = [srcx_weapon_sword, 96.0];
const _weapons_bow_short = [srcx_weapon_bow, 0.0];
const _helms_pointed_hat_purple = [srcx_helm, 32.0];
const _helms_pointed_hat_black = [srcx_helm, 64.0];
const _helms_leather_cap = [srcx_helm, 0.0];
const _helms_steel_cap = [srcx_helm, 128.0];
const _helms_feather_cap = [srcx_helm, 96.0];
const _helms_full_helm = [srcx_helm, 128.0];
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

List<double> getSrcAmuletItem(AmuletItem amuletItem) => switch (amuletItem) {
      AmuletItem.Weapon_Sword_Short => _weapons_sword_short,
      AmuletItem.Weapon_Sword_Broad => _weapons_sword_broad,
      AmuletItem.Weapon_Sword_Long => _weapons_sword_long,
      AmuletItem.Weapon_Sword_Giant => _weapons_sword_giant,
      AmuletItem.Weapon_Staff_Wand => const [srcx_weapon_staff, 0],
      AmuletItem.Weapon_Staff_Globe => const [srcx_weapon_staff, 32],
      AmuletItem.Weapon_Staff_Scepter => const [srcx_weapon_staff, 64],
      AmuletItem.Weapon_Staff_Long => const [34, 99, 28, 28],
      AmuletItem.Weapon_Bow_Short => _weapons_bow_short,
      AmuletItem.Weapon_Bow_Reflex => _weapons_bow_short,
      AmuletItem.Weapon_Bow_Composite => _weapons_bow_short,
      AmuletItem.Weapon_Bow_Long => _weapons_bow_short,
      AmuletItem.Helm_Leather_Cap => _helms_leather_cap,
      AmuletItem.Helm_Crooked_Hat => _helms_pointed_hat_purple,
      AmuletItem.Helm_Feathered_Cap => _helms_feather_cap,
      AmuletItem.Helm_Steel_Cap => _helms_steel_cap,
      AmuletItem.Helm_Pointed_Hat => _helms_pointed_hat_black,
      AmuletItem.Helm_Full => _helms_full_helm,
      AmuletItem.Helm_Veil => _helms_veil,
      AmuletItem.Armor_Tunic => _armor_tunic,
      AmuletItem.Armor_Leather => _armor_leather,
      AmuletItem.Armor_Chainmail => _armor_chainmail,
      AmuletItem.Armor_Platemail => _armor_platemail,
      AmuletItem.Armor_Robes => _armor_robe,
      AmuletItem.Armor_Cloak => _armor_cloak,
      AmuletItem.Armor_Mantle => _armor_mantle,
      AmuletItem.Armor_Shroud => _armor_shroud,
      AmuletItem.Shoes_Leather_Boots => _shoes_leather_boots,
      AmuletItem.Shoes_Black_Slippers => _shoes_black_slippers,
      AmuletItem.Shoes_Treads => _shoes_treads,
      AmuletItem.Shoes_Grieves => _shoes_grieves,
      AmuletItem.Shoes_Footwraps => _shoes_grieves,
      AmuletItem.Shoes_Striders => _shoes_grieves,
      AmuletItem.Shoes_Warrior_3_Sabatons_Common => _shoes_grieves,
      AmuletItem.Shoes_Soles => _shoes_grieves,
      AmuletItem.Shoes_Satin_Boots => _shoes_grieves,
      AmuletItem.Consumable_Potion_Health => const [srcx_consumable, 0],
      AmuletItem.Consumable_Potion_Magic => const [srcx_consumable, 64],
      AmuletItem.Helm_Cowl => _helms_pointed_hat_black,
      AmuletItem.Helm_Cape => _armor_mantle,
      AmuletItem.Unique_Weapon_Swift_Blade => const [
          srcx_weapon_sword,
          128,
          32,
          32
        ],
      AmuletItem.Assassins_Blade => _weapons_sword_short,
};
