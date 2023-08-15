import 'body_type.dart';
import 'hand_type.dart';
import 'helm_type.dart';
import 'leg_type.dart';
import 'object_type.dart';
import 'weapon_type.dart';
import 'item_type.dart';

class GameObjectType {
  static const Weapon = 1;
  static const Helm = 2;
  static const Body = 3;
  static const Legs = 4;
  static const Object = 5;
  static const Item = 6;
  static const Hand = 7;

  static const items = [
     Weapon, Helm, Body, Legs, Object, Item, Hand,
  ];

  static const Collection = {
    Weapon: WeaponType.values,
    Helm: HelmType.values,
    Body: BodyType.values,
    Legs: LegType.values,
    Hand: HandType.values,
    Object: ObjectType.values,
    Item: ItemType.values,
  };

  static String getName(int value) => const {
      Helm: 'Helm',
      Weapon: 'Weapon',
      Legs: 'Legs',
      Body: 'Body',
      Hand: 'Hands',
      Object: 'Object',
      Item: 'Consumable',
    }[value] ?? 'gameobject-type-unknown-$value';

  static String getNameSubType(int type, int subType) => switch (type) {
      Helm => HelmType.getName(subType),
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
    Helm,
    Object,
    Item,
  ];
}
