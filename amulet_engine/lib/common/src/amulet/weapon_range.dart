enum WeaponRange {
  Very_Short(melee: 50, ranged: 150),
  Short(melee: 70, ranged: 175),
  Long(melee: 90, ranged: 200),
  Very_Long(melee: 110, ranged: 225);

  final double melee;
  final double ranged;

  const WeaponRange({required this.melee, required this.ranged});

  int get quantify => (index * 4).toInt();
}
