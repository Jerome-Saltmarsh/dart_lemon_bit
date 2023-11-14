import 'package:gamestream_flutter/packages/common.dart';

class SpriteGroupType {
  static const Body_Male = 3;
  static const Body_Female = 4;
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
  static const Shoes = 20;

  static String getName(int value)=> const {
    Body_Male: 'body_male',
    Body_Female: 'body_female',
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
    Shoes: 'shoes',
  }[value] ?? (throw Exception('SpriteGroup.getName($value)'));

  static String getSubTypeName(int type, int subType) => switch (type) {
      Body_Male => BodyType.getName(subType),
      Body_Female => BodyType.getName(subType),
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
      Shoes => ShoeType.getName(subType),
      _ => throw Exception(
          'SpriteGroupType.getName(type: $type, subType: $subType)'
      ),
    };

  static const values = [
    Body_Male,
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
    Shoes,
  ];
}
