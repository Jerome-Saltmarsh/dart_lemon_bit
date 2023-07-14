class LegType {
  static const Nothing = 0;
  static const Red = 1;
  static const Blue = 2;
  static const White = 3;
  static const Green = 4;
  static const Brown = 5;
  static const Swat = 6;

  static String getName(int value) {
    return const {
      Nothing: 'Nothing',
      Red: 'Red',
      Blue: 'Blue',
      White: 'White',
      Green: 'Green',
      Brown: 'Brown',
      Swat: 'Swat',
    }[value] ?? 'leg-type-unknown';
  }

  static const values = [
    Red,
    Blue,
    White,
    Green,
    Brown,
    Swat,
  ];
}
