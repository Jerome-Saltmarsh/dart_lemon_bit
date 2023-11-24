
class SpellType {
  static const Thunderbolt = 0;
  static const Blink = 1;
  static const Heal = 2;
  static const Split_Arrow = 3;

  static const values = [
    Thunderbolt,
    Blink,
    Heal,
    Split_Arrow,
  ];

  static getName(int subType) => const {
    Thunderbolt: 'Thunderbolt',
    Blink: 'Blink',
    Heal: 'Heal',
    Split_Arrow: 'Split Arrow',
  } [subType] ?? (throw Exception('SpellType.getName($subType)'));
}