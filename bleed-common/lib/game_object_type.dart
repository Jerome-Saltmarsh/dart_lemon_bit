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

  static bool isStatic(int type){
    return const [
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
    ].contains(type);
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
    }[value] ?? "?";
  }
}
