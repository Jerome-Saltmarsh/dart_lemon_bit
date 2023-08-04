import 'body_type.dart';
import 'hand_type.dart';
import 'head_type.dart';
import 'leg_type.dart';
import 'object_type.dart';
import 'weapon_type.dart';
import 'item_type.dart';

class GameObjectType {
  static const Weapon = 1;
  static const Head = 2;
  static const Body = 3;
  static const Legs = 4;
  static const Hand = 5;
  static const Object = 6;
  static const Item = 7;
  static const Hands = 8;

  static const items = [
     Weapon, Head, Body, Legs, Hand, Object, Item
  ];

  static const Collection = {
    Weapon: WeaponType.values,
    Head: HeadType.values,
    Body: BodyType.values,
    Legs: LegType.values,
    Hand: HandType.values,
    Object: ObjectType.values,
    Item: ItemType.values,
  };

  static String getName(int value) => const {
      Weapon: 'Weapon',
      Legs: 'Legs',
      Body: 'Body',
      Head: 'Head',
      Hand: 'Hand',
      Object: 'Object',
      Item: 'Consumable',
    }[value] ?? 'gameobject-type-unknown-$value';

  static String getNameSubType(int type, int subType) => switch (type) {
      Head => HeadType.getName(subType),
      Body => BodyType.getName(subType),
      Legs => LegType.getName(subType),
      Object => ObjectType.getName(subType),
      Hand => HandType.getName(subType),
      Weapon => WeaponType.getName(subType),
      Item => ItemType.getName(subType),
      _ => throw Exception('GameObjectType.getNameSubType(type: $type, subType: $subType)')
    };

  static const values = [
    Weapon,
    Legs,
    Body,
    Head,
    Object,
    Item,
  ];
}
