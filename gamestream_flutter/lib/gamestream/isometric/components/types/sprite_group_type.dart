import 'package:gamestream_flutter/packages/common.dart';
import 'package:gamestream_flutter/packages/common/src/isometric/hair_type.dart';

class SpriteGroupType {
  static const Arms_Left = 1;
  static const Arms_Right = 2;
  static const Body = 3;
  static const Body_Arms = 4;
  static const Hands_Left = 5;
  static const Hands_Right = 6;
  static const Heads = 7;
  static const Helms = 8;
  static const Legs = 9;
  static const Shadow = 10;
  static const Torso = 11;
  static const Weapons = 12;
  static const Hair = 13;

  static String getName(int value)=> const {
    Arms_Left: 'arms_left',
    Arms_Right: 'arms_right',
    Body: 'body',
    Body_Arms: 'body_arms',
    Hands_Left: 'hands_left',
    Hands_Right: 'hands_right',
    Heads: 'head',
    Helms: 'helms',
    Legs: 'legs',
    Shadow: 'shadow',
    Torso: 'torso',
    Weapons: 'weapons',
    Hair: 'hair',
  }[value] ?? (throw Exception('SpriteGroup.getName($value)'));

  static String getSubTypeName(int type, int subType) => switch (type) {
      Arms_Left => 'regular',
      Arms_Right => 'regular',
      Body => BodyType.getName(subType),
      Body_Arms => BodyType.getName(subType),
      Hands_Left => HandType.getName(subType),
      Hands_Right => HandType.getName(subType),
      Heads => 'regular',
      Helms => HelmType.getName(subType),
      Legs => LegType.getName(subType),
      Torso => 'regular',
      Weapons => WeaponType.getName(subType),
      Shadow => 'regular',
      Hair => HairType.getName(subType),
      _ => throw Exception(
          'SpriteGroupType.getName(type: $type, subType: $subType)'
      ),
    };

  static const values = [
    Arms_Left,
    Arms_Right,
    Body,
    Body_Arms,
    Hands_Left,
    Hands_Right,
    Heads,
    Helms,
    Legs,
    Shadow,
    Torso,
    Weapons,
    Hair,
  ];
}
