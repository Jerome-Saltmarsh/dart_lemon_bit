

class HairType {
  static const none = 0;
  static const basic_1 = 1;

  static const values = [
    none,
    ...valuesNotNone,
  ];

  static const valuesNotNone = [
    basic_1,
  ];

  static getName(int subType) => const {
      none: 'none',
      basic_1: '00',
    }[subType] ?? (throw Exception());
}