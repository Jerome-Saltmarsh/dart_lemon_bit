
class HandType {
  static const None = 0;
  static const Gauntlet = 1;

  static String getName(int value) => const {
      None: 'None',
      Gauntlet: "Gauntlet",
    }[value] ?? 'hand-type-unknown-$value';
}