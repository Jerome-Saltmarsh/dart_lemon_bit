
class SpellType {
  static const Thunderbolt = 0;
  static const Blink = 1;
  static const Heal = 2;

  static const values = [
    Thunderbolt,
    Blink,
    Heal,
  ];

  static getName(int subType) => const {
    Thunderbolt: 'Thunderbolt',
    Blink: 'Blink',
    Heal: 'Heal',
  } [subType] ?? (throw Exception('SpellType.getName($subType)'));
}