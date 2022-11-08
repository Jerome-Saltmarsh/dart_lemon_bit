class InteractMode {
  static const None = 0;
  static const Talking = 1;
  static const Trading = 2;
  static const Inventory = 3;
  static const Craft = 4;

  static String getName(int value) => {
    None: "None",
    Talking: "Talking",
    Trading: "Trading",
    Inventory: "Inventory",
    Craft: "Craft",
  }[value] ?? "unknown-interact-mode($value)";
}