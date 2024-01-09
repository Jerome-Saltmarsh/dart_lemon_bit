class LegType {
  static const None = 0;
  static const Leather = 1;
  static const Plated = 2;
  static const Linen_Striped = 3;

  static String getName(int value) => const {
      None: 'none',
      Leather: 'leather',
      Plated: 'plated',
      Linen_Striped: 'linen_striped',
    }[value] ?? 'leg_type_unknown_$value';

  static const values = [
    Leather,
    Plated,
    Linen_Striped,
  ];
}
