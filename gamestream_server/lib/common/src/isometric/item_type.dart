
class ItemType {
  static const Health_Potion = 0;
  static const Magic_Potion = 1;
  static const Meat_Drumstick = 2;

  static String getName(int type) => const {
      Health_Potion: "Health_Potion",
      Magic_Potion: "Magic_Potion",
      Meat_Drumstick: "Meat_Drumstick",
    }[type] ?? 'unknown-consumable-type-$type';

  static const values = [
    Health_Potion,
    Magic_Potion,
    Meat_Drumstick,
  ];
}