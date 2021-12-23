
import 'package:bleed_client/common/WeaponType.dart';

class Weapon {
  WeaponType type;
  int damage;
  int capacity;
  int rounds;

  Weapon({
    required this.type,
    required this.damage,
    required this.capacity,
    required this.rounds
  });
}