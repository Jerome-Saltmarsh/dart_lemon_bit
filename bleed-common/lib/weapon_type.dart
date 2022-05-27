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

  static int getDamage(int type) {
    return const <int, int> {
      Unarmed: 1,
      Bow: 1,
      Sword: 1,
      Staff: 1,
      Shotgun: 1,
    } [type] ?? 0;
  }

  static double getRange(int type) {
    return const <int, double> {
      Unarmed: 20,
      Bow: 250,
      Sword: 30,
      Staff: 180,
    } [type] ?? 0;
  }

  static bool isMelee(int type){
    return const <int>[Sword, Unarmed].contains(type);
  }
}
