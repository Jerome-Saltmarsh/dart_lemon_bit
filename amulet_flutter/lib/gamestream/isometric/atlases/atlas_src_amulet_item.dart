import 'package:amulet_engine/packages/isometric_engine/packages/common/src/amulet/amulet_item.dart';

const _weapon_sword = 64.0;
const _weapon_bow = 96.0;
const _consumable = 128.0;

const atlasSrcAmuletItem = <AmuletItem, List<double>> {
  AmuletItem.Weapon_Sword_1_5_Common: [_weapon_sword, 0],
  AmuletItem.Weapon_Sword_1_5_Rare: [_weapon_sword, 0],
  AmuletItem.Weapon_Sword_1_5_Legendary: [_weapon_sword, 0],
  AmuletItem.Weapon_Bow_1_5_Common: [_weapon_bow, 0],
  AmuletItem.Weapon_Bow_1_5_Rare: [_weapon_bow, 0],
  AmuletItem.Weapon_Bow_1_5_Legendary: [_weapon_bow, 0],
  AmuletItem.Consumable_Potion_Health: [_consumable, 32],
  AmuletItem.Consumable_Potion_Magic: [_consumable, 64],
};