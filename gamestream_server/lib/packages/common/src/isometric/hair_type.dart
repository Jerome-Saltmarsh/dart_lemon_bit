

class HairType {
  static const none = 0;
  static const basic_1 = 1;
  static const basic_2 = 2;
  static const basic_3 = 3;

  static const values = [
    none,
    basic_1,
    basic_2,
    basic_3,
  ];

  static getName(int subType) => const {
      none: 'none',
      basic_1: '1',
      basic_2: '2',
      basic_3: '3',
    }[subType] ?? (throw Exception());
}