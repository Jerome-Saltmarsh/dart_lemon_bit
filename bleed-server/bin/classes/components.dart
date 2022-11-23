import 'package:lemon_math/library.dart';


mixin Velocity {
  var mass = 1.0;
  /// Velocity X
  var velocityX = 0.0;
  /// Velocity Y
  var velocityY = 0.0;
  var maxSpeed = 20.0;

  double get velocitySpeed => getHypotenuse(velocityX, velocityY);
  double get velocityAngle => getAngle(velocityX, velocityY);

  void set velocitySpeed(double value){
    assert (value >= 0);
    final currentAngle = velocityAngle;
    velocityX = getAdjacent(currentAngle, value);
    velocityY = getOpposite(currentAngle, value);
  }

  void setVelocity(double angle, double speed){
     velocityX = getAdjacent(angle, speed);
     velocityY = getOpposite(angle, speed);
  }

  void applyFriction(double amount){
    velocityX *= amount;
    velocityY *= amount;
  }

  void applyForce({
    required double force,
    required double angle,
  }) {
    velocityX += getAdjacent(angle, force);
    velocityY += getOpposite(angle, force);
    if (velocitySpeed > maxSpeed) {
       velocitySpeed = maxSpeed;
    }
  }
}

