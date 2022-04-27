import 'package:bleed_common/library.dart';
import 'package:lemon_math/library.dart';

import '../../maths.dart';
import 'mixins.dart';

class Collectable extends Vector2 with Type {
  Collectable() : super(0, 0);
}

class Character extends Vector2 {
  bool scoreMeasured = false;
  int score = 0;
  int state;
  int direction;
  int frame;
  int equipped = TechType.Unarmed;
  int armour = TechType.Unarmed;
  int helm = TechType.Unarmed;
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
  bool get running => state == CharacterState.Running;
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
