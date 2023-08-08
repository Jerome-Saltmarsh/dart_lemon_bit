import 'dart:math';
import 'package:gamestream_flutter/common.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:lemon_math/src.dart';

class Character extends Position {
  var characterType = CharacterType.Template;
  var weaponType = WeaponType.Unarmed;
  var weaponState = 0;
  var complexionType = ComplexionType.Fair;
  var bodyType = 0;
  var headType = 0;
  var legType = 0;
  var handTypeLeft = 0;
  var handTypeRight = 0;
  var state = 0;
  var team = 0;
  var direction = 0;
  var animationFrame = 0;
  var name = '';
  var text = '';
  var allie = false;
  /// percentage between 0 and 1
  var health = 1.0;
  /// percentage between 0 and 1
  var magic = 1.0;
  var lookDirection = 0;
  var weaponStateDuration = 0;
  var color = 0;

  static const piSixteenth = pi / 16.0;

  double get radius => CharacterType.getRadius(characterType);

  bool get weaponStateIdle => weaponState == WeaponState.Idle;
  bool get weaponStatePerforming => weaponState == WeaponState.Performing;
  bool get weaponStateReloading => weaponState == WeaponState.Reloading;
  bool get weaponStateChanging => weaponState == WeaponState.Changing;
  bool get weaponStateAiming => weaponState == WeaponState.Aiming;
  bool get weaponEngaged => weaponStateAiming || weaponStatePerforming;
  bool get dead => state == CharacterState.Dead;
  bool get spawning => state == CharacterState.Spawning;
  bool get running => state == CharacterState.Running;
  bool get striking => weaponState == WeaponState.Performing;
  bool get performing => state == CharacterState.Performing;
  bool get hurt => state == CharacterState.Hurt;
  bool get alive => !dead;
  bool get unarmed => weaponType == WeaponType.Unarmed;
  bool get weaponTypeIsShotgun => weaponType == WeaponType.Shotgun;
  int get renderDirection => (direction - 1) % 8;
  int get renderLookDirection => (lookDirection - 1) % 8;
  double get angle => direction * piQuarter;
}
