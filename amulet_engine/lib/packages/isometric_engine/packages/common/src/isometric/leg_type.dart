class LegType {
  static const None = 0;
  static const Leather = 1;
  static const Plated = 2;

  static String getName(int value) => const {
      None: 'None',
      Leather: 'leather',
      Plated: 'plated',
    }[value] ?? 'leg_type_unknown_$value';

  static const values = [
    Leather,
    Plated,
  ];
}
