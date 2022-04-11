import 'package:bleed_common/CharacterState.dart';
import 'package:bleed_common/SlotType.dart';
import 'package:lemon_math/Vector2.dart';

import '../maths.dart';


class Character extends Vector2 {
  bool scoreMeasured = false;
  int score = 0;
  int state;
  int direction;
  int frame;
  int equippedWeapon = SlotType.Empty;
  int equippedArmour = SlotType.Empty;
  int equippedHead = SlotType.Empty;
  // int team;
  String name;
  String text;
  bool allie = false;
  /// percentage between 0 and 1
  double health = 1;
  /// percentage between 0 and 1
  double magic = 1;

  // properties
  bool get dead => state == stateDead;
  bool get running => state == stateRunning;
  bool get alive => !dead;
  double get angle => direction * piQuarter;

  Character({
    this.state = 0,
    this.direction = 0,
    double x = 0,
    double y = 0,
    this.frame = 0,
    this.name = "",
    this.text = "",
  }): super(x, y);
}
