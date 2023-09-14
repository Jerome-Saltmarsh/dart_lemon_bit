

class ShoeType {
  static const None = 0;
  static const Boots = 1;

  static String getName(int value) => const {
      None: 'None',
      Boots: 'Boots',
  }[value] ?? (throw Exception());

}