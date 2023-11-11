
class ConsumableType {
  static const Potion_Red = 0;
  static const Potion_Blue = 1;
  static const Potion_Green = 2;
  static const Potion_Yellow = 3;
  static const Meat_Drumstick = 4;

  static String getName(int type) => const {
      Potion_Red: 'Health_Potion',
      Potion_Blue: 'Potion_Blue',
      Potion_Green: 'Potion_Green',
      Potion_Yellow: 'Potion_Yellow',
      Meat_Drumstick: 'Meat_Drumstick',
    }[type] ?? 'unknown-consumable-type-$type';

  static const values = [
    Potion_Red,
    Potion_Blue,
    Potion_Green,
    Potion_Yellow,
    Meat_Drumstick,
  ];
}