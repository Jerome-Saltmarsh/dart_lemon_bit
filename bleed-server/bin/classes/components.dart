import 'dart:math';

import '../common/MaterialType.dart';
import '../maths.dart';
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
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;

  double get angleVelocity => atan2(xv, yv);

  void applyFriction(double amount){
    xv *= amount;
    yv *= amount;
  }

  void accelerate(double rotation, double acceleration) {
    xv += adj(rotation, acceleration);
    yv += opp(rotation, acceleration);
  }

  void setVelocity(double rotation, double speed){
    xv = adj(rotation, speed);
    yv = opp(rotation, speed);
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

