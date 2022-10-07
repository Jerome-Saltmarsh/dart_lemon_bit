class GameObjectType {
  static const Flower = 1;
  static const Rock = 2;
  static const Stick = 3;
  static const Butterfly = 4;
  static const Chicken = 5;
  static const Crystal = 6;
  static const Barrel = 7;
  static const Wheel = 8;
  static const Candle = 9;
  static const Bottle = 10;
  static const Chest = 11;
  static const Cup = 12;
  static const Wooden_Shelf_Row = 13;
  static const Book_Purple = 14;
  static const Crystal_Small_Blue = 15;
  static const Flower_Green = 16;
  static const Tavern_Sign = 18;
  static const Jellyfish = 19;
  static const Jellyfish_Red = 20;
  static const Lantern_Red = 21;
  static const Loot = 22;
  static const Particle_Emitter = 23;
  static const Weapon_Shotgun = 27;
  static const Weapon_Handgun = 28;
  static const Weapon_Blade = 29;

  static const staticValues = [
    Flower,
    Rock,
    Stick,
    Crystal,
    Barrel,
    Wheel,
    Candle,
    Bottle,
    Chest,
    Cup,
    Wooden_Shelf_Row,
    Book_Purple,
    Crystal_Small_Blue,
    Flower_Green,
    Tavern_Sign,
    Lantern_Red,
    Particle_Emitter,
  ];

  static bool isCollidable(int type) =>
    type == Barrel;

  static bool isPersistable(int type) =>
    type == Barrel;

  static bool emitsLightBright(int type){
    if (type == Jellyfish) return true;
    if (type == Jellyfish_Red) return true;
    if (type == Lantern_Red) return true;
    return false;
  }

  static bool emitsBubbles(int type){
    if (type == Jellyfish) return true;
    if (type == Jellyfish_Red) return true;
    if (type == Flower) return true;
    return false;
  }

  static bool isStatic(int type){
    return staticValues.contains(type);
  }
  
  static String getName(int value){
    return const <int, String> {
       Flower: "Flower",
       Rock: "Rock",
       Stick: "Stick",
       Butterfly: "Butterfly",
       Chicken: "Chicken",
       Crystal: "Crystal",
       Chest: "Chest",
       Barrel: "Barrel",
       Wheel: "Wheel",
       Candle: "Candle",
       Bottle: "Bottle",
       Cup: "Cup",
       Wooden_Shelf_Row: "Wooden Shelf Row",
       Book_Purple: "Book Purple",
       Crystal_Small_Blue: "Crystal Small Blue",
       Flower_Green: "Flower Green",
       Tavern_Sign: "Tavern Sign",
       Jellyfish: "Jelly Fish",
       Jellyfish_Red: "Jelly Fish Red",
       Lantern_Red: "Lantern Red",
       Particle_Emitter: "Particle Emitter",
       Weapon_Handgun: "Handgun",
       Weapon_Shotgun: "Shotgun",
       Weapon_Blade: "Blade",
    }[value] ?? "?";
  }
}
