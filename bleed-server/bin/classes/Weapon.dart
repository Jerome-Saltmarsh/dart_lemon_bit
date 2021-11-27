
import '../common/WeaponType.dart';

class Weapon {
  WeaponType type;
  int damage;
  int capacity;
  late int rounds;

  Weapon({
    required this.type,
    required this.damage,
    required this.capacity,
  }) {
    rounds = capacity;
  }
}