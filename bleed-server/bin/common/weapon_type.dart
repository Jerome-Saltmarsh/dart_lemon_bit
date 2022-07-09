class WeaponType {
  static const Unarmed = 0;
  static const Sword = 1;
  static const Bow = 2;
  static const Staff = 3;
  static const Shotgun = 4;
  static const Handgun = 5;
  static const Hammer = 6;
  static const Axe = 7;
  static const Pickaxe = 8;

  static const values = [
    Unarmed,
    Sword,
    Bow,
    Staff,
    Shotgun,
    Handgun,
    Hammer,
    Axe,
    Pickaxe,
  ];

  static String getName(int type) {
    return const <int, String>{
      Unarmed: "Unarmed",
      Bow: "Bow",
      Sword: "Sword",
      Staff: "Staff",
      Shotgun: "Shotgun",
      Handgun: "Handgun",
      Hammer: "Hammer",
      Axe: "Axe",
      Pickaxe: "Pickaxe",
    } [type] ?? "Unknown";
  }

  static double getRange(int type) {
    return const <int, double> {
      Unarmed: 20,
      Bow: 250,
      Sword: 30,
      Staff: 180,
      Shotgun: 220,
      Handgun: 180,
    } [type] ?? 0;
  }

  static bool isMelee(int type) {
    return type == Sword ||
           type == Staff ||
           type == Pickaxe ||
           type == Hammer ||
           type == Axe ;

  }
  
  static bool isMetal(int type){
    return const [Sword, Pickaxe, Axe, Hammer].contains(type);
  }
}
