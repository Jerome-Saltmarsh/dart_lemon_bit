

class ShoeType {
  static const None = 0;
  static const Leather_Boots = 1;
  static const Iron_Plates = 2;

  static String getName(int value) => const {
      None: 'None',
      Leather_Boots: 'Leather Boots',
      Iron_Plates: 'Iron Plates',
  }[value] ?? (throw Exception('ShoeType.getName($value)'));

}