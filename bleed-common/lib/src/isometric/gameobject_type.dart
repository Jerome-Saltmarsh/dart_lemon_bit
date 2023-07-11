import 'body_type.dart';
import 'head_type.dart';
import 'leg_type.dart';
import 'object_type.dart';
import 'weapon_type.dart';

class GameObjectType {
  static const Nothing = 0;
  static const Weapon = 1;
  static const Legs = 2;
  static const Body = 3;
  static const Head = 4;
  static const Object = 5;

  static const items = [
     Weapon, Legs, Body, Head
  ];

  static const Collection = {
    Object: ObjectType.values,
    Head: HeadType.values,
    Body: BodyType.values,
    Legs: LegType.values,
    Weapon: WeaponType.values,
  };

  static String getName(int value) => const {
      Nothing: "Nothing",
      Weapon: "Weapon",
      Legs: "Legs",
      Body: "Body",
      Head: "Head",
      Object: "Object",
    }[value] ?? 'gameobject-type-unknown-$value';

  static String getNameSubType(int type, int subType) => switch (type) {
      Nothing => 'Nothing',
      Head => HeadType.getName(subType),
      Body => BodyType.getName(subType),
      Legs => LegType.getName(subType),
      Object => ObjectType.getName(subType),
      Weapon => WeaponType.getName(subType),
      _ => throw Exception('GameObjectType.getNameSubType(type: $type, subType: $subType)')
    };

  static const values = [
    // Nothing,
    Weapon,
    Legs,
    Body,
    Head,
    Object,
  ];
}
