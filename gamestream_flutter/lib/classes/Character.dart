import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/CharacterType.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:lemon_math/Vector2.dart';

import '../maths.dart';

class Character extends Vector2 {
  CharacterType type;
  CharacterState state;
  int direction;
  int frame;
  SlotType equippedWeapon = SlotType.Empty;
  SlotType equippedArmour = SlotType.Empty;
  SlotType equippedHead = SlotType.Empty;
  // int team;
  String name;
  String text;
  bool allie = false;
  /// percentage between 0 and 1
  double health = 1;
  /// percentage between 0 and 1
  double magic = 1;

  // properties
  bool get dead => state == CharacterState.Dead;
  bool get alive => state != CharacterState.Dead;
  double get angle => direction * piQuarter;

  Character({
    required this.type,
    this.state = CharacterState.Idle,
    this.direction = 0,
    double x = 0,
    double y = 0,
    this.frame = 0,
    this.name = "",
    this.text = "",
  }): super(x, y);
}
