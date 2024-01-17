

class ShoeType {
  static const None = 0;
  // warrior
  static const Boots = 1;
  static const Grieves = 2;
  static const Sabatons = 3;
  // wizard
  static const Slippers = 4;
  static const Footwraps = 5;
  static const Soles = 6;
  // rogue
  static const Treads = 7;
  static const Striders = 8;
  static const Satin_Boots = 9;

  static String getName(int value) => const {
    None: 'None',
    Boots: 'Boots',
    Grieves: 'Grieves',
    Sabatons: 'Sabatons',
    Slippers: 'Slippers',
    Footwraps: 'Footwraps',
    Soles: 'Soles',
    Treads: 'Treads',
    Striders: 'Striders',
    Satin_Boots: 'Satin_Boots',
  }[value] ?? (throw Exception('ShoeType.getName($value)'));

  static const values = [
    Boots,
    Grieves,
    Sabatons,
    Slippers,
    Footwraps,
    Soles,
    Treads,
    Striders,
    Satin_Boots,
  ];

}