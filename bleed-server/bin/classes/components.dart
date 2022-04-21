import 'dart:math';

import '../maths.dart';
import '../utilities.dart';

mixin Team {
  var team = 0;
}

mixin Health {
  var _health = 1;
  var maxHealth = 1;

  bool get dead => _health <= 0;

  bool get alive => _health > 0;

  int get health => _health;

  set health(int value) {
    _health = clampInt(value, 0, maxHealth);
  }
}

mixin Velocity {
  var z = 0.0;
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;

  double get angle => atan2(xv, yv);

  void applyForce(double rotation, double amount) {
    xv += adj(rotation, amount);
    yv += opp(rotation, amount);
  }
}

mixin Active {
  bool active = true;
}
