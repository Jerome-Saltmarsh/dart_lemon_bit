
import '../common/WeaponType.dart';
import '../utilities.dart';

class Weapon {
  WeaponType type;
  int damage;
  int capacity;
  late int _rounds;

  Weapon({
    required this.type,
    required this.damage,
    required this.capacity,
    int? rounds
  }) {
    this.rounds = rounds ?? capacity;
  }

  int get rounds => _rounds;

  set rounds(int value){
    _rounds = clampInt(value, 0, capacity);
  }
}