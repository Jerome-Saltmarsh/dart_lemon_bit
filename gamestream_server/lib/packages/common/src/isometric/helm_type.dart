
class HelmType {
  static const None = 0;
  static const Steel = 1;
  static const Wizard_Hat = 2;

  static const values = [
    None,
    Steel,
    Wizard_Hat,
  ];

  static String getName(int value) => const {
    None: 'none',
    Steel: 'steel',
    Wizard_Hat: 'Wizard Hat',
  }[value] ?? (throw Exception());
}