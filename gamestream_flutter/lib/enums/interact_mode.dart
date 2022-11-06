class InteractMode {
  static const None = 0;
  static const Talking = 1;
  static const Trading = 2;
  static const Inventory = 3;

  static String getName(int value) => {
    None: "None",
    Talking: "Talking",
    Trading: "Trading",
    Inventory: "Inventory",
  }[value] ?? "unknown-interact-mode($value)";
}