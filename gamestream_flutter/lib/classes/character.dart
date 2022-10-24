import 'dart:math';

import 'package:bleed_common/library.dart';
import 'package:lemon_math/library.dart';

import 'vector3.dart';

class Character extends Vector3 {
  var characterType = CharacterType.Template;
  var weaponType = AttackType.Unarmed;
  var weaponState = AttackType.Unarmed;
  var bodyType = BodyType.shirtCyan;
  var headType = HeadType.None;
  var legType = LegType.white;
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

  bool get usingWeapon => weaponFrame > 0 || performing;
  bool get dead => state == CharacterState.Dead;
  bool get deadOrDying => dead || dying;
  bool get spawning => state == CharacterState.Spawning;
  bool get running => state == CharacterState.Running;
  bool get performing => state == CharacterState.Performing;
  bool get hurt => state == CharacterState.Hurt;
  bool get dying => state == CharacterState.Dying;
  bool get alive => !dead;
  int get aimDirection => ((lookRadian - (pi / 16.0)) ~/ piQuarter + 4) % 8;
  double get angle => direction * piQuarter;
  int get renderDirection => direction == 0 ? 7 : (direction - 1);

  bool get unarmed => weaponType == AttackType.Unarmed;
  bool get weaponTypeIsShotgun => weaponType == AttackType.Shotgun;
}
