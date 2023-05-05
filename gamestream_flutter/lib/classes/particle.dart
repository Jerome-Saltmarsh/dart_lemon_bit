import 'package:gamestream_flutter/library.dart';

class Particle extends Vector3 {
  var delay = 0;
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;
  var frame = 0;
  var weight = 0.0;
  var duration = 0;
  var durationTotal = 0;
  var rotation = 0.0;
  var rotationVelocity = 0.0;
  var scale = 0.0;
  var scaleV = 0.0;
  var type = 0;
  var bounciness = 0.0;
  /// Deactivates if this node hits a solid node
  var checkNodeCollision = true;
  var animation = false;

  var lightHue = 0;
  var lightSaturation = 0;
  var lightValue = 0;
  var alpha = 0;
  var strength = 0.0;
  var flash = true;
  var emitsLight = false;

  bool get active => duration > 0;
  int get direction => Direction.fromRadian(rotation);
  double get duration01 => duration / durationTotal;

  void setSpeed(double angle, double speed){
    xv = adj(angle, speed);
    yv = opp(angle, speed);
  }

  void deactivate(){
    duration = -1;
    durationTotal = -1;
    frame = 0;
  }

  void setAngle({required double value, required double speed}){
    xv = adj(value, speed);
    yv = opp(value, speed);
  }

  void updateMotion(){
    x += xv;
    y += yv;
    z += zv;
    if (z < 0){
      z = 0;
    }
    if (rotationVelocity != 0){
      rotation = clampAngle(rotation + rotationVelocity);
    }
    if (scaleV != 0){
      scale += scaleV;
      if (scale < 0){
        scale = 0;
      }
    }
  }

  void applyAirFriction(){
    const gravity = 0.04;
    const airFriction = 0.98;
    zv -= gravity * weight;
    xv *= airFriction;
    yv *= airFriction;
  }

  void applyFloorFriction(){
    const floorFriction = 0.9;
    const rotationFriction = 0.93;
    xv *= floorFriction;
    yv *= floorFriction;
    rotationVelocity *= rotationFriction;
  }

  void applyLimits(){
    if (scale < 0) {
      scale = 0;
    }
    if (z <= 0) {
      z = 0;
    }
  }
}

