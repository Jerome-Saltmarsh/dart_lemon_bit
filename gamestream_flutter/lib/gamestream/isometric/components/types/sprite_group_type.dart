import 'package:gamestream_flutter/packages/common.dart';

class SpriteGroupType {
  static const Arms_Left = 1;
  static const Arms_Right = 2;
  static const Body_Male = 3;
  static const Body_Female = 4;
  static const Body_Arms = 5;
  static const Hands_Left = 6;
  static const Hands_Right = 7;
  static const Heads = 8;
  static const Helms = 9;
  static const Legs = 10;
  static const Shadow = 11;
  static const Torso_Top = 12;
  static const Torso_Bottom = 13;
  static const Weapons = 14;
  static const Hair = 17;
  static const Shoes_Left = 18;
  static const Shoes_Right = 19;

  static String getName(int value)=> const {
    Arms_Left: 'arms_left',
    Arms_Right: 'arms_right',
    Body_Male: 'body_male',
    Body_Female: 'body_female',
    Body_Arms: 'body_arms',
    Hands_Left: 'hands_left',
    Hands_Right: 'hands_right',
    Heads: 'head',
    Helms: 'helms',
    Legs: 'legs',
    Shadow: 'shadow',
    Torso_Top: 'torso_top',
    Torso_Bottom: 'torso_bottom',
    Weapons: 'weapons',
    Hair: 'hair',
    Shoes_Left: 'shoes_left',
    Shoes_Right: 'shoes_right',
  }[value] ?? (throw Exception('SpriteGroup.getName($value)'));

  static String getSubTypeName(int type, int subType) => switch (type) {
      Arms_Left => 'regular',
      Arms_Right => 'regular',
      Body_Male => BodyType.getName(subType),
      Body_Female => BodyType.getName(subType),
      Body_Arms => BodyType.getName(subType),
      Hands_Left => HandType.getName(subType),
      Hands_Right => HandType.getName(subType),
      Heads => HeadType.getName(subType),
      Helms => HelmType.getName(subType),
      Legs => LegType.getName(subType),
      Torso_Top => Gender.getName(subType),
      Torso_Bottom => Gender.getName(subType),
      Weapons => WeaponType.getName(subType),
      Shadow => 'regular',
      Hair => HairType.getName(subType),
      Shoes_Left => ShoeType.getName(subType),
      Shoes_Right => ShoeType.getName(subType),
      _ => throw Exception(
          'SpriteGroupType.getName(type: $type, subType: $subType)'
      ),
    };

  static const values = [
    Arms_Left,
    Arms_Right,
    Body_Male,
    Body_Arms,
    Hands_Left,
    Hands_Right,
    Heads,
    Helms,
    Legs,
    Shadow,
    Torso_Top,
    Torso_Bottom,
    Weapons,
    Hair,
    Shoes_Left,
  ];
}
