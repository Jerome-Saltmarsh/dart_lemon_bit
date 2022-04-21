


import 'package:lemon_math/Vector2.dart';

import 'Collider.dart';
import 'components.dart';

class Structure extends Collider with Team, Health {
  var cooldown = 0;
  int attackRate;
  int attackDamage;
  double attackRange;
  int type; // StructureType.dart

  Structure({
    required this.type,
    required double x,
    required double y,
    required int team,
    required this.attackRate,
    required this.attackDamage,
    this.attackRange = 200.0,
  }) : super(x: x, y: y, radius: 25) {
    this.team = team;
  }

  bool withinRange(Vector2 value) {
    return getDistance(value) < attackRange;
  }
}