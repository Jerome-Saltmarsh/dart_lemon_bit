import 'body_type.dart';
import 'consumable_type.dart';
import 'hand_type.dart';
import 'helm_type.dart';
import 'leg_type.dart';
import 'object_type.dart';
import 'treasure_type.dart';
import 'weapon_type.dart';

class ItemType {
  static const Weapon = 1;
  static const Helm = 2;
  static const Body = 3;
  static const Legs = 4;
  static const Object = 5;
  static const Consumable = 6;
  static const Hand = 7;
  static const Treasure = 8;

  static const collections = {
    Weapon: WeaponType.values,
    Helm: HelmType.values,
    Body: BodyType.values,
    Legs: LegType.values,
    Hand: HandType.values,
    Object: ObjectType.values,
    Consumable: ConsumableType.values,
    Treasure: TreasureType.values,
  };

  static String getName(int value) => const {
      Helm: 'Helm',
      Weapon: 'Weapon',
      Legs: 'Legs',
      Body: 'Body',
      Hand: 'Hands',
      Object: 'Object',
      Consumable: 'Consumable',
    }[value] ?? 'gameobject-type-unknown-$value';

  static String getNameSubType(int type, int subType) => switch (type) {
      Helm => HelmType.getName(subType),
      Body => BodyType.getName(subType),
      Legs => LegType.getName(subType),
      Object => ObjectType.getName(subType),
      Hand => HandType.getName(subType),
      Weapon => WeaponType.getName(subType),
      Consumable => ConsumableType.getName(subType),
      Treasure => TreasureType.getName(subType),
      _ => throw Exception('GameObjectType.getNameSubType(type: $type, subType: $subType)')
    };

  static int compress(int type, int subType) => type << 8 | subType;

  static int decompressSubType(int compressed) => compressed & 0xFF;

  static int decompressType(int compressed) => (compressed >> 8) & 0xFF;

  static const values = [
    Weapon,
    Legs,
    Body,
    Helm,
    Object,
    Consumable,
    Treasure,
  ];
}
