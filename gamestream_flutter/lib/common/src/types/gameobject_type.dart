import '../../../common.dart';

class GameObjectType {
  static const Weapon = 1;
  static const Helm = 2;
  static const Body = 3;
  static const Legs = 4;
  static const Object = 5;
  static const Item = 6;
  static const Hand = 7;
  static const Treasure = 8;

  static const items = [
     Weapon, Helm, Body, Legs, Object, Item, Hand, Treasure,
  ];

  static const Collection = {
    Weapon: WeaponType.values,
    Helm: HelmType.values,
    Body: BodyType.values,
    Legs: LegType.values,
    Hand: HandType.values,
    Object: ObjectType.values,
    Item: ItemType.values,
    Treasure: TreasureType.values,
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

  static int compress(int type, int subType) => type << 8 | subType;

  static int decompressSubType(int compressed) => compressed & 0xFF;

  static int decompressType(int compressed) => (compressed >> 8) & 0xFF;

  static const values = [
    Weapon,
    Legs,
    Body,
    Helm,
    Object,
    Item,
  ];
}
