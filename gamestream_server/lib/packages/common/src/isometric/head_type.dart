

class HeadType {
  static const boy = 0;
  static const girl = 1;

  static const values = [
    boy,
    girl,
  ];

  static getName(int subType) => const {
      boy: 'boy',
      girl: 'girl'
  }[subType] ?? (throw Exception());
}