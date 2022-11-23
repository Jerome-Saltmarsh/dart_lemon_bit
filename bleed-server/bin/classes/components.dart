import 'package:lemon_math/library.dart';

import 'collider.dart';

mixin Owner <T> {
  late T owner;
}

// mixin Team {
//   var team = 0;
// }

bool onSameTeam(dynamic a, dynamic b){
  if (a == b) return true;
  if (a is Collider == false) return false;
  if (b is Collider == false) return false;
  if (a.team == 0) return false;
  return a.team == b.team;
}

mixin Velocity {
  var mass = 1.0;
  /// Velocity X
  var xv = 0.0;
  /// Velocity Y
  var yv = 0.0;
  var maxSpeed = 20.0;

  double get velocitySpeed => getHypotenuse(xv, yv);
  double get velocityAngle => getAngle(xv, yv);

  void set velocitySpeed(double value){
    assert (value >= 0);
    final currentAngle = velocityAngle;
    xv = getAdjacent(currentAngle, value);
    yv = getOpposite(currentAngle, value);
  }

  void setVelocity(double angle, double speed){
     xv = getAdjacent(angle, speed);
     yv = getOpposite(angle, speed);
  }

  void applyFriction(double amount){
    xv *= amount;
    yv *= amount;
  }

  void applyForce({
    required double force,
    required double angle,
  }) {
    xv += getAdjacent(angle, force);
    yv += getOpposite(angle, force);
    if (velocitySpeed > maxSpeed) {
       velocitySpeed = maxSpeed;
    }
  }
}

mixin Target<T> {
  late T target;
}

mixin Radius {
  var radius = 0.0;
}

// mixin Type<T> {
//   late T type;
// }

// mixin Id {
//   static var _id = 0;
//   var id = _id++;
// }

