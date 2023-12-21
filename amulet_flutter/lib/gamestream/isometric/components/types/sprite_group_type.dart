import 'package:amulet_engine/packages/common.dart';

class SpriteGroupType {
  static const Body_Male = 3;
  static const Body_Female = 4;
  static const Hand_Left = 6;
  static const Hand_Right = 7;
  static const Head = 8;
  static const Helm = 9;
  static const Legs = 10;
  static const Shadow = 11;
  static const Torso = 12;
  static const Weapon = 14;
  static const Weapon_Trail = 15;
  static const Hair = 17;
  static const Shoes = 20;

  static String getName(int value)=> const {
    Body_Male: 'body_male',
    Body_Female: 'body_female',
    Hand_Left: 'hands_left',
    Hand_Right: 'hands_right',
    Head: 'head',
    Helm: 'helms',
    Legs: 'legs',
    Shadow: 'shadow',
    Torso: 'torso',
    Weapon: 'weapons',
    Hair: 'hair',
    Shoes: 'shoes',
    Weapon_Trail: 'weapons_trail',
  }[value] ?? (throw Exception('SpriteGroup.getName($value)'));

  static String getSubTypeName(int type, int subType) => switch (type) {
      Body_Male => BodyType.getName(subType),
      Body_Female => BodyType.getName(subType),
      Hand_Left => HandType.getName(subType),
      Hand_Right => HandType.getName(subType),
      Head => HeadType.getName(subType),
      Helm => HelmType.getName(subType),
      Legs => LegType.getName(subType),
      Torso => Gender.getName(subType),
      Weapon => WeaponType.getName(subType),
      Weapon_Trail => WeaponType.getName(subType),
      Shadow => 'regular',
      Hair => HairType.getName(subType),
      Shoes => ShoeType.getName(subType),
      _ => throw Exception(
          'SpriteGroupType.getName(type: $type, subType: $subType)'
      ),
    };
  // static const values = [
  //   Body_Male,
  //   Hand_Left,
  //   Hand_Right,
  //   Head,
  //   Helm,
  //   Legs,
  //   Shadow,
  //   Torso,
  //   Weapon,
  //   Hair,
  //   Shoes,
  // ];
}
