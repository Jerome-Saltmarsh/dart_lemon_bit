
class ConsumableType {
  static const Health_Potion = 0;
  static const Magic_Potion = 1;

  static String getName(int type) => const {
      Health_Potion: "Health_Potion",
      Magic_Potion: "Magic_Potion",
    }[type] ?? 'unknown-consumable-type-$type';

  static const values = [
    Health_Potion,
    Magic_Potion,
  ];
}