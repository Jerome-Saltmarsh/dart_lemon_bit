
class SpawnType {
  static const Zombie = 0;
  static const Chicken = 1;
  static const Butterfly = 2;
  static const Rat = 3;

  static String getName(int type) {
    return const {
      Zombie: "Zombie",
      Chicken: "Chicken",
      Butterfly: "Butterfly",
      Rat: "Rat",
    } [type] ?? "Unknown ($type)";
  }
}