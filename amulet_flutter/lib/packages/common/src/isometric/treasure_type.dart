
class TreasureType {
  static const Pendant_1 = 0;

  static const values = [
    Pendant_1,
  ];

  static String getName(int type) => const {
    Pendant_1: 'Pendant_1',
  }[type] ?? 'unknown-type-$type';
}