
import '../common/WeaponType.dart';

class Weapon {
  WeaponType type;
  int damage = 5;

  Weapon({required this.type, required this.damage});
}