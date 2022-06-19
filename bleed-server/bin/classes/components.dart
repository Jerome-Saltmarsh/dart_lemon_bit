import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/opposite.dart';

import '../common/MaterialType.dart';
import '../utilities.dart';

mixin Owner <T> {
  late T owner;
}

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
  var angle = 0.0;
  var speed = 0.0;

  double get xv => getAdjacent(angle, speed);
  double get yv => getOpposite(angle, speed);

  void applyFriction(double amount){
    speed *= amount;
  }

  void accelerate(double rotation, double acceleration) {
    speed += acceleration;
  }
}

mixin Active {
  bool active = true;

  bool get inactive => !active;

  void deactivate(){
    active = false;
  }
}

mixin Target<T> {
  late T target;
}

mixin Duration {
  var duration = 0;
}

mixin Radius {
  var radius = 0.0;
}

mixin Type<T> {
  late T type;
}

mixin Material {
  late MaterialType material;
}

mixin Id {
  static var _id = 0;
  var id = _id++;
}

