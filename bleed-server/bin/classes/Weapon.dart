
import '../common/WeaponType.dart';

class Weapon {
  WeaponType type;
  int damage;
  int capacity;

  Weapon({
    required this.type,
    required this.damage,
    required this.capacity,
  });
}