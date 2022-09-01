import 'dart:math';

import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/opposite.dart';
import 'package:lemon_math/library.dart';

import '../common/Direction.dart';
import '../common/MaterialType.dart';

mixin Owner <T> {
  late T owner;
}

mixin Team {
  var team = 0;
}

mixin Velocity {
  var angle = 0.0;
  var speed = 0.0;
  var mass = 1.0;

  void set direction(int value) => angle = convertDirectionToAngle(value);
  int get direction => convertAngleToDirection(angle);

  /// TODO HACK (Why is pi being added here?)
  double get xv => getAdjacent(angle + pi, speed);
  /// TODO HACK (Why is pi being added here?)
  double get yv => getOpposite(angle + pi, speed);

  void setVelocity(double x, double y){

  }

  void applyFriction(double amount){
    speed *= amount;
  }

  void applyForce({
    required double force,
    required double angle,
  }) {
    final accelerationX = getAdjacent(angle, force);
    final accelerationY = getOpposite(angle, force);

    final xv2 = xv + accelerationX;
    final yv2 = yv + accelerationY;

    speed = getHypotenuse(xv2, yv2);
    angle = getAngle(xv2, yv2);
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

