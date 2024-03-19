
import 'package:amulet_common/src.dart';

class SpriteGroupType {
  static const Armor = 2;
  static const Head = 8;
  static const Helm = 9;
  static const Shadow = 11;
  static const Torso = 12;
  static const Weapon = 14;
  static const Hair = 17;
  static const Shoes = 20;

  static String getName(int value)=> const {
    Armor: 'armor',
    Head: 'head',
    Helm: 'helms',
    Shadow: 'shadow',
    Torso: 'torso',
    Weapon: 'weapons',
    Hair: 'hair',
    Shoes: 'shoes',
  }[value] ?? (throw Exception('SpriteGroup.getName($value)'));

  static String getSubTypeName(int type, int subType) => switch (type) {
      Armor => ArmorType.getName(subType),
      Head => HeadType.getName(subType),
      Helm => HelmType.getName(subType),
      Torso => Gender.getName(subType),
      Weapon => WeaponType.getName(subType),
      Shadow => 'regular',
      Hair => HairType.getName(subType),
      Shoes => ShoeType.getName(subType),
      _ => throw Exception(
          'SpriteGroupType.getName(type: $type, subType: $subType)'
      ),
    };
}
