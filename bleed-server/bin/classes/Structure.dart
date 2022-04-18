


import 'package:lemon_math/Vector2.dart';

import 'Character.dart';
import 'Collider.dart';

class Structure extends Collider with Team {
  var cooldown = 0;
  int attackRate;
  double range;
  Structure({
    required double x,
    required double y,
    required int team,
    required this.attackRate,
    this.range = 200.0,
  }) : super(x, y, 25) {
    this.team = team;
  }

  bool withinRange(Vector2 value) {
    return getDistance(value) < range;
  }
}