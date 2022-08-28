
class SpawnType {
  static const Zombie = 0;
  static const Chicken = 1;
  static const Butterfly = 2;
  static const Rat = 3;
  static const Jellyfish = 4;
  static const Jellyfish_Red = 5;

  static int getValue(int index){
    const max = Jellyfish_Red;
    if (index < 0) return Zombie;
    if (index > max) return max;
    return index;
  }

  static String getName(int type) {
    return const {
      Zombie: "Zombie",
      Chicken: "Chicken",
      Butterfly: "Butterfly",
      Rat: "Rat",
      Jellyfish: "Jellyfish",
      Jellyfish_Red: "Jellyfish Red",
    } [type] ?? "Unknown ($type)";
  }
}