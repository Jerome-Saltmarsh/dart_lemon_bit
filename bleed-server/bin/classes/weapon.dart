
import 'package:lemon_math/library.dart';

import '../common/attack_state.dart';
import '../common/attack_type.dart';
import '../functions/generateUUID.dart';

class Weapon {
   int type;
   int damage;
   int capacity;
   var state = AttackState.Idle;
   double range;
   late int _rounds;
   int duration;
   var charge = 0;
   var durationRemaining = 0;
   dynamic spawn;
   final uuid = generateUUID();

   int get rounds => _rounds;

   int get frame => durationRemaining > 0 ? duration - durationRemaining : 0;

   bool get requiresRounds => capacity > 0;

   double get durationPercentage => durationRemaining / duration;

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
      damage: 3,
      capacity: 8,
      duration: 20,
      range: 250,
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
      damage: 4,
      capacity: 20,
      duration: 10,
      range: 200,
    );

Weapon buildWeaponAssaultRifle() =>
    Weapon(
      type: AttackType.Assault_Rifle,
      damage: 3,
      capacity: 100,
      duration: 4,
      range: 300,
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
      range: 300,
   );

Weapon buildWeaponCrossBow() =>
    Weapon(
      type: AttackType.Crossbow,
      damage: 1,
      capacity: 15,
      duration: 30,
      range: 200,
    );

Weapon buildWeaponStaff() =>
    Weapon(
      type: AttackType.Staff,
      damage: 5,
      capacity: 15,
      duration: 10,
      range: 200,
    );

/// TODO implement
Weapon buildWeaponBaseballBat() =>
    Weapon(
      type: AttackType.Blade,
      damage: 3,
      duration: 20,
      range: 60,
    );

Weapon buildWeaponBlade() =>
    Weapon(
      type: AttackType.Blade,
      damage: 3,
      duration: 20,
      range: 60,
      capacity: 15,
    );

Weapon buildWeaponUnarmed({int damage = 1}) =>
    Weapon(
       type: AttackType.Unarmed,
       damage: damage,
       capacity: 0,
       duration: 10,
       range: 35,
    );