enum AreaDamage {
  Very_Small(value: 0.25),
  Small(value: 0.50),
  Large(value: 0.75),
  Very_Large(value: 1.0);

  final double value;

  const AreaDamage({required this.value});

  static AreaDamage from(double value) {
    for (final areaDamage in values) {
      if (areaDamage.value > value) continue;
      return areaDamage;
    }
    return values.last;
  }

  int get quantify {
    return (value * 6).toInt();
  }
}
