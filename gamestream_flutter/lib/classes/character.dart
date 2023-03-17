import 'dart:math';

import 'package:bleed_common/src.dart';
import 'package:lemon_math/src.dart';

import 'vector3.dart';

class Character extends Vector3 {
  var characterType = CharacterType.Template;
  var weaponType = ItemType.Empty;
  var weaponState = 0;
  var bodyType = 0;
  var headType = 0;
  var legType = 0;
  var state = 0;
  var direction = 0;
  var frame = 0;
  var name = "";
  var text = "";
  var allie = false;
  /// percentage between 0 and 1
  var health = 1.0;
  /// percentage between 0 and 1
  var magic = 1.0;
  var lookRadian = 0.0;
  var weaponFrame = 0;
  var color = 0;
  var buff = 0;

  bool get buffInvincible     => buff & 0x00000001 == 1;
  bool get buffDoubleDamage   => buff & 0x00000002 == 2;
  bool get buffInvisible      => buff & 0x00000004 == 4;
  bool get buffStunned        => buff & 0x00000008 == 8;

  static const piSixteenth = pi / 16.0;

  double get radius => CharacterType.getRadius(characterType);

  bool get weaponStateIdle => weaponState == WeaponState.Idle;
  bool get weaponStateFiring => weaponState == WeaponState.Firing;
  bool get weaponStateMelee => weaponState == WeaponState.Melee;
  bool get weaponStateReloading => weaponState == WeaponState.Reloading;
  bool get weaponStateChanging => weaponState == WeaponState.Changing;
  bool get weaponStateAiming => weaponState == WeaponState.Aiming;
  bool get weaponStateThrowing => weaponState == WeaponState.Throwing;
  bool get dead => state == CharacterState.Dead;
  bool get spawning => state == CharacterState.Spawning;
  bool get running => state == CharacterState.Running;
  bool get performing => state == CharacterState.Performing;
  bool get hurt => state == CharacterState.Hurt;
  bool get alive => !dead;
  bool get unarmed => weaponType == ItemType.Empty;
  bool get weaponTypeIsShotgun => weaponType == ItemType.Weapon_Ranged_Shotgun;
  int get aimDirection => ((lookRadian - (piSixteenth)) ~/ piQuarter + 4) % 8;
  int get renderDirection => direction == 0 ? 7 : (direction - 1);
  double get angle => direction * piQuarter;
}
