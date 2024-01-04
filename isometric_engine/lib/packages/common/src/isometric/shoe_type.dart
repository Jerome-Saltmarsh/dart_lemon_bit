

class ShoeType {
  static const None = 0;
  static const Leather_Boots = 1;
  static const Iron_Plates = 2;
  static const Black_Boots = 3;

  static String getName(int value) => const {
      None: 'None',
      Leather_Boots: 'Leather Boots',
      Iron_Plates: 'Iron Plates',
      Black_Boots: 'Black_Boots',
  }[value] ?? (throw Exception('ShoeType.getName($value)'));

  static const values = [
    Leather_Boots,
    Iron_Plates,
    Black_Boots,
  ];

}