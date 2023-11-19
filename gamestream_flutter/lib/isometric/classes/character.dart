import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_math/src.dart';

class Character extends Position {
  var characterType = CharacterType.Human;
  var weaponType = WeaponType.Unarmed;
  var complexion = 0;
  var shoeType = ShoeType.None;
  var bodyType = 0;
  var helmType = 0;
  var headType = 0;
  var hairType = 0;
  var hairColor = 0;
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
  var color = 0;
  var actionComplete = 0.0;
  var gender = 0;

  bool get dead => state == CharacterState.Dead;

  bool get spawning => state == CharacterState.Spawning;

  bool get running => state == CharacterState.Running;

  int get renderDirection => (direction - 1) % 8;

  double get angle => direction * piQuarter;

}
