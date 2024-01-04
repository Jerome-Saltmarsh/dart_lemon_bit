
class HelmType {
  static const None = 0;
  static const Steel = 1;
  static const Wizard_Hat = 2;
  static const Witches_Hat = 3;

  static const values = [
    Steel,
    Wizard_Hat,
    Witches_Hat,
  ];

  static String getName(int value) => const {
    None: 'none',
    Steel: 'steel',
    Wizard_Hat: 'Wizard Hat',
    Witches_Hat: 'Witches_Hat',
  }[value] ?? (throw Exception());
}