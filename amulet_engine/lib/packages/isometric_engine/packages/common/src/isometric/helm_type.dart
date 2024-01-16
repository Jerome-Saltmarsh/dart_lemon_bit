
class HelmType {
  static const None = 0;
  // Warrior
  static const Leather_Cap = 1;
  static const Steel_Cap = 2;
  static const Steel_Helm = 3;
  // Wizard
  static const Pointed_Hat_Purple = 4;
  static const Pointed_Hat_Black = 5;
  static const Circlet = 6;
  // ROGUE
  static const Hood = 7;
  static const Cape = 8;
  static const Veil = 9;

  static const values = [
    Leather_Cap,
    Steel_Cap,
    Steel_Helm,
    Pointed_Hat_Purple,
    Pointed_Hat_Black,
    Circlet,
    Hood,
    Cape,
    Veil,
  ];

  static String getName(int value) => const {
    None: 'none',
    Leather_Cap: 'Leather_Cap',
    Steel_Cap: 'Steel_Cap',
    Steel_Helm: 'Steel_Helm',
    Pointed_Hat_Purple: 'Pointed_Hat_Purple',
    Pointed_Hat_Black: 'Pointed_Hat_Black',
    Circlet: 'Circlet',
    Hood: 'Hood',
    Cape: 'Cape',
    Veil: 'Veil',
  }[value] ?? (throw Exception());
}