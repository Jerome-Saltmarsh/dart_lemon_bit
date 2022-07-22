import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:lemon_math/constants/pi_quarter.dart';

import 'vector3.dart';

class Character extends Vector3 {
  var type = CharacterType.Template;
  var scoreMeasured = false;
  var score = 0;
  var state = 0;
  var direction = 0;
  var frame = 0;
  var complexion = 0;
  var weapon = WeaponType.Unarmed;
  var armour = ArmourType.shirtCyan;
  var helm = HeadType.None;
  var pants = PantsType.white;
  var name = "";
  var text = "";
  var allie = false;
  /// percentage between 0 and 1
  double health = 1;
  /// percentage between 0 and 1
  double magic = 1;

  // properties
  bool get dead => state == CharacterState.Dead;
  bool get running => state == CharacterState.Running;
  bool get performing => state == CharacterState.Performing;
  bool get alive => !dead;
  double get angle => direction * piQuarter;
}
