
class ItemType {
  static const Health_Potion = 0;
  static const Magic_Potion = 1;
  static const Meat_Drumstick = 2;
  static const Pendant_1 = 3;
  

  static String getName(int type) => const {
      Health_Potion: "Health_Potion",
      Magic_Potion: "Magic_Potion",
      Meat_Drumstick: "Meat_Drumstick",
      Pendant_1: "Pendant_1",
    }[type] ?? 'unknown-consumable-type-$type';

  static const values = [
    Health_Potion,
    Magic_Potion,
    Meat_Drumstick,
    Pendant_1,
  ];
}