class LegType {
  static const None = 0;
  static const Leather = 1;

  static String getName(int value) => const {
      None: 'None',
      Leather: 'leather',
    }[value] ?? 'leg-type-unknown';

  static const values = [
    Leather
  ];
}
