
class GameObjectType {
  static const Crate_Wooden = 7;
  static const Candle = 13;
  static const Barrel = 14;
  static const Cup = 16;
  static const Bed = 25;
  static const Bottle = 31;
  static const Crystal_Glowing_False = 12;
  static const Crystal_Glowing_True = 41;
  static const Interactable = 45;
  static const Wooden_Cart = 46;
  static const Broom = 47;
  static const Firewood = 48;
  static const Pumpkin = 49;
  static const Wooden_Chest = 50;
  static const Rune = 51;
  static const Shrine = 52;

  static bool isMaterialMetal(int value) => const [
      // Barrel_Explosive
  ].contains(value);

  static double getRadius(int value){
    return 15.0;
  }

  static String getName(int value) {
    return const {
      Crate_Wooden: 'Crate_Wooden',
      Crystal_Glowing_False: 'Crystal',
      Candle: 'Candle',
      Barrel: 'Barrel',
      Cup: 'Cup',
      Bed: 'Bed',
      Bottle: 'Bottle',
      Crystal_Glowing_True: 'Crystal Glowing',
      Interactable: 'Interactable',
      Wooden_Cart: 'Wooden_Cart',
      Broom: 'Broom',
      Firewood: 'Firewood',
      Pumpkin: 'Pumpkin',
      Wooden_Chest: 'Wooden_Chest',
      Rune: 'Rune',
      Shrine: 'Shrine',
    }[value] ?? 'object-type-unknown-$value';
  }

  static const values = [
    Crate_Wooden,
    Crystal_Glowing_False,
    Candle,
    Barrel,
    Cup,
    Bed,
    Bottle,
    Crystal_Glowing_True,
    Interactable,
    Wooden_Cart,
    Broom,
    Firewood,
    Pumpkin,
    Wooden_Chest,
    Rune,
    Shrine,
  ];
}