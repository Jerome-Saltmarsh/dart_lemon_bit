


import 'package:lemon_math/Vector2.dart';

import 'Character.dart';
import 'Collider.dart';

class Structure extends Collider with Team, Health {
  var cooldown = 0;
  int attackRate;
  double attackRange;

  Structure({
    required double x,
    required double y,
    required int team,
    required this.attackRate,
    this.attackRange = 200.0,
  }) : super(x, y, 25) {
    this.team = team;
  }

  bool withinRange(Vector2 value) {
    return getDistance(value) < attackRange;
  }
}