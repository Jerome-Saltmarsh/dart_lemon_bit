
class HelmType {
  static const None = 0;
  // Warrior
  static const Leather_Cap = 1;
  static const Steel_Helm = 2;
  static const Great_Helm = 3;
  // Wizard
  static const Pointed_Hat = 4;
  static const Circlet = 5;
  static const Crest = 6;
  // ROGUE
  static const Hood = 7;
  static const Cape = 8;
  static const Veil = 9;

  static const values = [
    Leather_Cap,
    Steel_Helm,
    Great_Helm,
    Pointed_Hat,
    Circlet,
    Crest,
    Hood,
    Cape,
    Veil,
  ];

  static String getName(int value) => const {
    None: 'none',
    Leather_Cap: 'Leather_Cap',
    Steel_Helm: 'Steel_Helm',
    Great_Helm: 'Great_Helm',
    Pointed_Hat: 'Pointed_Hat',
    Circlet: 'Circlet',
    Crest: 'Crest',
    Hood: 'Hood',
    Cape: 'Cape',
    Veil: 'Veil',
  }[value] ?? (throw Exception());
}