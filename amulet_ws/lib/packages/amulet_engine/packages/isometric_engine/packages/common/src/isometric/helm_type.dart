
class HelmType {
  static const None = 0;
  // Warrior
  static const Leather_Cap = 1;
  static const Steel_Cap = 2;
  static const Steel_Helm = 3;
  // Wizard
  static const Pointed_Hat_Purple = 4;
  static const Pointed_Hat_Black = 5;
  static const Cowl = 6;
  // ROGUE
  static const Feather_Cap = 7;
  static const Hood = 8;
  static const Cape = 9;

  static const values = [
    Leather_Cap,
    Steel_Cap,
    Steel_Helm,
    Pointed_Hat_Purple,
    Pointed_Hat_Black,
    Cowl,
    Feather_Cap,
    Hood,
    Cape,
  ];

  static String getName(int value) => const {
    None: 'none',
    Leather_Cap: 'Leather_Cap',
    Steel_Cap: 'Steel_Cap',
    Steel_Helm: 'Steel_Helm',
    Pointed_Hat_Purple: 'Pointed_Hat_Purple',
    Pointed_Hat_Black: 'Pointed_Hat_Black',
    Cowl: 'Cowl',
    Hood: 'Hood',
    Cape: 'Cape',
    Feather_Cap: 'Feather_Cap',
  }[value] ?? (throw Exception());
}