import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/common/src.dart';
import 'package:lemon_math/src.dart';

class Particle extends Position {

  var frictionAir = 0.98;
  var wind = 0;
  var active = false;
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
  var scaleVelocity = 0.0;
  var type = 0;
  var bounciness = 0.0;
  /// Deactivates if this node hits a solid node
  var deactiveOnNodeCollision = true;
  var nodeCollidable = true;
  var animation = false;
  var nodeType = 0;
  var nodeIndex = 0;

  var emissionColor = 0;
  var emissionIntensity = 0.0;
  var flash = true;
  var emitsLight = false;

  Particle({super.x, super.y, super.z, this.active = false});

  int get direction => IsometricDirection.fromRadian(rotation);

  double get duration01 => duration / durationTotal;

  void setSpeed(double angle, double speed){
    xv = adj(angle, speed);
    yv = opp(angle, speed);
  }

  void deactivate(){
    active = false;
    duration = -1;
    durationTotal = -1;
    frame = 0;
    delay = 0;
  }

  void setAngle({required double value, required double speed}){
    xv = adj(value, speed);
    yv = opp(value, speed);
  }

  void applyMotion(){
    x += xv;
    y += yv;
    z += zv;
    if (z < 0){
      z = 0;
    }
    if (rotationVelocity != 0) {
      rotation = (rotation + rotationVelocity) % pi2;
    }
    if (scaleVelocity != 0) {
      scale += scaleVelocity;
      if (scale < 0){
        scale = 0;
      }
    }
  }

  void applyAirFriction(){
    const gravity = 0.04;
    zv -= gravity * weight;
    xv *= frictionAir;
    yv *= frictionAir;
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
      deactivate();
    }
    if (z <= 0) {
      z = 0;
      deactivate();
    }
  }

  @override
  String toString() {
    return '{x: ${x.toInt()}, y: ${y.toInt()}, z: ${z.toInt()}, active: $active, type: ${ParticleType.getName(type)}';
  }

  static int compare(Particle a, Particle b){
     final aActive = a.active;
     final bActive = b.active;

     if (!aActive && !bActive)
       return 0;

     if (aActive && !bActive)
        return -1;

     if (!aActive && bActive)
       return 1;

     return a.compareTo(b);
  }

  void update(){
    duration++;
    if (durationTotal >= 0 && duration >= durationTotal) {
      deactivate();
    }
  }
}

