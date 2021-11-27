
import 'package:bleed_client/common/WeaponType.dart';

class Weapon {
  WeaponType type;
  int damage;
  int capacity;
  int rounds;
  Weapon({this.type, this.damage, this.capacity, this.rounds});
}