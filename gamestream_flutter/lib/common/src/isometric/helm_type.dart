
class HelmType {
  static const None = 0;
  static const Steel = 1;
  static const Rogues_Hood = 2;
  static const Wizards_Hat = 3;

  static const values = [
    None,
    Steel,
  ];

  static String getName(int value) => const {
    None: 'none',
    Steel: 'steel',
    Rogues_Hood: 'Rogues Hood',
    Wizards_Hat: 'Wizards Hat',
  }[value] ?? (throw Exception());
}