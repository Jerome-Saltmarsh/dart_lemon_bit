import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:lemon_math/library.dart';

import 'vector3.dart';

class Character extends Vector3 {
  var type = CharacterType.Template;
  var state = 0;
  var direction = 0;
  var frame = 0;
  var weapon = AttackType.Unarmed;
  var weaponState = AttackType.Unarmed;
  var armour = ArmourType.shirtCyan;
  var helm = HeadType.None;
  var pants = PantsType.white;
  var name = "";
  var text = "";
  var allie = false;
  /// percentage between 0 and 1
  var health = 1.0;
  /// percentage between 0 and 1
  var magic = 1.0;
  var aimAngle = 0.0;

  bool get dead => state == CharacterState.Dead;
  bool get deadOrDying => dead || dying;
  bool get spawning => state == CharacterState.Spawning;
  bool get running => state == CharacterState.Running;
  bool get performing => state == CharacterState.Performing;
  bool get hurt => state == CharacterState.Hurt;
  bool get dying => state == CharacterState.Dying;
  bool get alive => !dead;
  int get aimDirection => ((aimAngle - piEighth) ~/ piQuarter + 4) % 8;
  double get angle => direction * piQuarter;
}
