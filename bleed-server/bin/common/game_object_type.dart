class GameObjectType {
  static const Flower = 1;
  static const Rock = 2;
  static const Stick = 3;
  static const Butterfly = 4;
  static const Chicken = 5;
  static const Crystal = 6;
  static const Chest = 10;
  
  static String getName(int value){
    return const <int, String> {
       Flower: "Flower",
       Rock: "Rock",
       Stick: "Stick",
       Butterfly: "Butterfly",
       Chicken: "Chicken",
       Crystal: "Crystal",
       Chest: "Chest",
    }[value] ?? "?";
  }
}
