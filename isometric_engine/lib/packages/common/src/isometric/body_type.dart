class BodyType {
  static const None = 0;
  static const Shirt_Blue = 1;
  static const Leather_Armour = 2;
  static const Black_Cloak = 3;

  static String getName(int value) =>
      const {
        Shirt_Blue: 'shirt_blue',
        Leather_Armour: 'leather_armour',
        Black_Cloak: 'black_cloak',
      }[value] ?? 'unknown-body-type-$value';

  static const values = [
    Shirt_Blue,
    Leather_Armour,
    Black_Cloak
  ];
}
