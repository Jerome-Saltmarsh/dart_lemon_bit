import 'dart:math';

import 'package:lemon_math/functions/adjacent.dart';
import 'package:lemon_math/functions/opposite.dart';

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

  void set direction(int value) => angle = convertDirectionToAngle(value);
  int get direction => convertAngleToDirection(angle);

  double get xv => getAdjacent(angle + pi, speed);
  double get yv => getOpposite(angle + pi, speed);

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

