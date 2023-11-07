

class HairType {
  static const none = 0;
  static const basic_1 = 1;
  // static const basic_2 = 2;

  static const values = [
    none,
    ...valuesNotNone,
  ];

  static const valuesNotNone = [
    basic_1,
    // basic_2,
  ];

  static getName(int subType) => const {
      none: 'none',
      basic_1: '01',
      // basic_2: '02',
    }[subType] ?? (throw Exception());
}