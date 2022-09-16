
import 'package:lemon_math/library.dart';

import '../common/attack_type.dart';
import '../functions/generateUUID.dart';

class Weapon {
   int type;
   int damage;
   int capacity;
   double range;
   late int _rounds;
   int duration;
   final uuid = generateUUID();

   int get rounds => _rounds;

   set rounds(int value) {
     _rounds = clamp(value, 0, capacity);
   }

   Weapon({
      required this.type,
      required this.damage,
      required this.duration,
      required this.range,
      this.capacity = 0,
   }) {
      _rounds = capacity;
   }
}

Weapon buildWeaponShotgun() =>
    Weapon(
      type: AttackType.Shotgun,
      damage: 1,
      capacity: 8,
      duration: 10,
      range: 200,
    );

Weapon buildWeaponRifle() =>
    Weapon(
      type: AttackType.Rifle,
      damage: 10,
      capacity: 8,
      duration: 25,
      range: 350,
    );

Weapon buildWeaponRevolver() =>
    Weapon(
      type: AttackType.Revolver,
      damage: 20,
      capacity: 5,
      duration: 35,
      range: 250,
    );

Weapon buildWeaponHandgun() =>
    Weapon(
      type: AttackType.Handgun,
      damage: 1,
      capacity: 20,
      duration: 10,
      range: 200,
    );

Weapon buildWeaponFireball() =>
    Weapon(
      type: AttackType.Fireball,
      damage: 1,
      capacity: 20,
      duration: 10,
      range: 200,
    );

Weapon buildWeaponBow() =>
   Weapon(
      type: AttackType.Bow,
      damage: 1,
      capacity: 15,
      duration: 30,
      range: 200,
   );

Weapon buildWeaponStaff() =>
    Weapon(
      type: AttackType.Staff,
      damage: 1,
      capacity: 5,
      duration: 10,
      range: 200,
    );


Weapon buildWeaponBlade() =>
    Weapon(
      type: AttackType.Blade,
      damage: 3,
      duration: 20,
      range: 100,
    );

Weapon buildWeaponUnarmed({int damage = 1}) =>
    Weapon(
       type: AttackType.Unarmed,
       damage: damage,
       capacity: 0,
       duration: 10,
       range: 50,
    );