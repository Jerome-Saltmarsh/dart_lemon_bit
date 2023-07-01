import 'dart:math';

import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:lemon_math/src.dart';

class IsometricCharacter extends IsometricPosition {
  var characterType = CharacterType.Template;
  var weaponType = ItemType.Empty;
  var weaponState = 0;
  var bodyType = 0;
  var headType = 0;
  var legType = 0;
  var state = 0;
  var direction = 0;
  var frame = 0;
  var name = '';
  var text = '';
  var allie = false;
  /// percentage between 0 and 1
  var health = 1.0;
  /// percentage between 0 and 1
  var magic = 1.0;
  var lookDirection = 0;
  var weaponFrame = 0;
  var color = 0;

  static const piSixteenth = pi / 16.0;

  double get radius => CharacterType.getRadius(characterType);

  bool get weaponStateIdle => weaponState == WeaponState.Idle;
  bool get weaponStateFiring => weaponState == WeaponState.Firing;
  bool get weaponStateMelee => weaponState == WeaponState.Melee;
  bool get weaponStateReloading => weaponState == WeaponState.Reloading;
  bool get weaponStateChanging => weaponState == WeaponState.Changing;
  bool get weaponStateAiming => weaponState == WeaponState.Aiming;
  bool get weaponStateThrowing => weaponState == WeaponState.Throwing;
  bool get weaponEngaged => weaponStateAiming || weaponStateFiring || weaponStateMelee;
  bool get dead => state == CharacterState.Dead;
  bool get spawning => state == CharacterState.Spawning;
  bool get running => state == CharacterState.Running;
  bool get performing => state == CharacterState.Performing;
  bool get hurt => state == CharacterState.Hurt;
  bool get alive => !dead;
  bool get unarmed => weaponType == ItemType.Empty;
  bool get weaponTypeIsShotgun => weaponType == ItemType.Weapon_Ranged_Shotgun;
  int get renderDirection => (direction - 1) % 8;
  int get renderLookDirection => (lookDirection - 1) % 8;
  double get angle => direction * piQuarter;
}
