import '../src.dart';

class ItemType {
  static const Weapon = 1;
  static const Helm = 2;
  static const Armor = 3;
  static const Shoes = 4;
  static const Object = 5;
  static const Consumable = 6;
  static const Amulet_Item = 8;

  static const collections = {
    Weapon: WeaponType.values,
    Helm: HelmType.values,
    Armor: ArmorType.values,
    Object: GameObjectType.values,
    Consumable: ConsumableType.values,
  };

  static String getName(int value) => const {
      Helm: 'Helm',
      Weapon: 'Weapon',
      Armor: 'Armor',
      Object: 'Object',
      Consumable: 'Consumable',
      Shoes: 'Shoes',
      Amulet_Item: 'Amulet_Item',
  }[value] ?? 'gameobject-type-unknown-$value';

  static String getNameSubType(int type, int subType) => switch (type) {
      Helm => HelmType.getName(subType),
      Armor => ArmorType.getName(subType),
      Object => GameObjectType.getName(subType),
      Weapon => WeaponType.getName(subType),
      Consumable => ConsumableType.getName(subType),
      Shoes => ShoeType.getName(subType),
      _ => throw Exception('GameObjectType.getNameSubType(type: $type, subType: $subType)')
    };

  static int compress(int type, int subType) => type << 8 | subType;

  static int decompressSubType(int compressed) => compressed & 0xFF;

  static int decompressType(int compressed) => (compressed >> 8) & 0xFF;

  static const values = [
    Weapon,
    // Legs,
    Armor,
    Helm,
    Object,
    Consumable,
    Shoes,
  ];
}
