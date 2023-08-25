
class HandType {
  static const None = 0;
  static const Gauntlets = 1;

  static String getName(int value) => const {
      None: 'none',
      Gauntlets: 'gauntlets',
    }[value] ?? 'hand-type-unknown-$value';

  static const values = [
    None,
    Gauntlets,
  ];
}