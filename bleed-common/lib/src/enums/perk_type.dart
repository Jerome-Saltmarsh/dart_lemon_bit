
class PerkType {
  static const None   = 0;
  static const Health = 1;
  static const Energy = 2;
  static const Power  = 4;
  static const Speed  = 3;
  
  static const values = [
    Health,
    Energy,
    Speed,
    Power,
  ];
  
  static String getName(int value) => const <int, String> {
    None   : "None",
    Health : "Health",
    Energy : "Energy",
    Speed  : "Speed",
    Power  : "Power",
  }[value] ?? '?';
}
