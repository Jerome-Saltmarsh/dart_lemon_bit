
import '../common/attack_type.dart';
import '../functions/generateUUID.dart';

class Weapon {
   int type;
   int damage;
   int capacity;
   double range;
   late int rounds;
   int duration;
   final uuid = generateUUID();

   Weapon({
      required this.type,
      required this.damage,
      required this.duration,
      required this.range,
      this.capacity = 0,
   }) {
      rounds = capacity;
   }
}

Weapon buildWeaponBow() =>
   Weapon(
      type: AttackType.Bow,
      damage: 1,
      capacity: 0,
      duration: 10,
      range: 200,
   );

Weapon buildWeaponStaff() =>
    Weapon(
      type: AttackType.Staff,
      damage: 1,
      capacity: 0,
      duration: 10,
      range: 200,
    );


Weapon buildWeaponSword() =>
    Weapon(
      type: AttackType.Blade,
      damage: 1,
      capacity: 0,
      duration: 10,
      range: 200,
    );

Weapon buildWeaponUnarmed({int damage = 1}) =>
    Weapon(
       type: AttackType.Unarmed,
       damage: damage,
       capacity: 0,
       duration: 10,
       range: 50,
    );