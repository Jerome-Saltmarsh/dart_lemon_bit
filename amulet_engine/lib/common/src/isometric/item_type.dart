import '../src.dart';

class ItemType {
  static const Object = 5;
  static const Amulet_Item = 8;

  static String getName(int value) => const {
      Object: 'Object',
      Amulet_Item: 'Amulet_Item',
  }[value] ?? 'gameobject-type-unknown-$value';

  static String getNameSubType(int type, int subType) => switch (type) {
      Object => GameObjectType.getName(subType),
      _ => throw Exception('GameObjectType.getNameSubType(type: $type, subType: $subType)')
    };

  static int compress(int type, int subType) => type << 8 | subType;

  static int decompressSubType(int compressed) => compressed & 0xFF;

  static int decompressType(int compressed) => (compressed >> 8) & 0xFF;

  static const values = [
    Object,
    Amulet_Item,
  ];
}
