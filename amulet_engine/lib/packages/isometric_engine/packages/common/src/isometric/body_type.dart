class BodyType {
  static const None = 0;
  static const Shirt_Blue = 1;
  // WARRIOR
  static const Leather_Armour = 2;
  static const Scalemail = 3;
  static const Platemail = 4;
  static const Chainmail = 5;
  static const Splintmail = 6;
  static const Brigandine = 7;
  static const Black_Cloak = 8;
  static const Tunic = 9;
  // WIZARD
  static const Cowl = 10;
  static const Robe = 11;
  static const Garb = 12;
  static const Attire = 13;
  // ROGUE
  static const Cloak = 14;
  static const Mantle = 15;
  static const Shroud = 16;

  static String getName(int value) =>
      const {
        Shirt_Blue: 'shirt_blue',
        Leather_Armour: 'leather_armour',
        Black_Cloak: 'black_cloak',
        Tunic: 'tunic',
        Cowl: 'cowl',
      }[value] ?? 'unknown-body-type-$value';

  static const values = [
    Shirt_Blue,
    Leather_Armour,
    Black_Cloak,
    Tunic,
    Cowl,
  ];
}
