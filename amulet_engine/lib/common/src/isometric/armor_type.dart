class ArmorType {
  static const None = 0;
  // NEUTRAL
  static const Tunic = 1;
  // WARRIOR
  static const Leather = 2;
  static const Chainmail = 3;
  static const Platemail = 4;
  // WIZARD
  static const Robes = 5;
  static const Garb = 6;
  static const Attire = 7;
  // ROGUE
  static const Cloak = 8;
  static const Mantle = 9;
  static const Shroud = 10;

  static String getName(int value) =>
      const {
        Tunic: 'tunic',
        Leather: 'leather',
        Chainmail: 'chainmail',
        Platemail: 'platemail',
        Robes: 'robes',
        Garb: 'garb',
        Attire: 'Attire',
        Cloak: 'Cloak',
        Mantle: 'Mantle',
        Shroud: 'Shroud',
      }[value] ?? 'unknown-body-type-$value';

  static const values = [
    Tunic,
    Leather,
    Chainmail,
    Platemail,
    Robes,
    Garb,
    Attire,
    Cloak,
    Mantle,
    Shroud,
  ];
}
