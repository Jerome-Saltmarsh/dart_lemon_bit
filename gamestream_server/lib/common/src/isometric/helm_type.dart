
class HelmType {
  static const None = 0;
  static const Steel = 1;

  static const values = [
    None,
    Steel,
  ];

  static String getName(int value) => const {
      None: 'none',
      Steel: 'steel',
    }[value] ?? (throw Exception());
}