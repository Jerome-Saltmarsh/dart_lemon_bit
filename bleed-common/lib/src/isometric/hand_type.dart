
class HandType {
  static const None = 0;
  static const Gauntlet = 1;

  static String getName(int value) => const {
      None: 'none',
      Gauntlet: 'gauntlet',
    }[value] ?? 'hand-type-unknown-$value';

  static const values = [
    None,
    Gauntlet,
  ];
}