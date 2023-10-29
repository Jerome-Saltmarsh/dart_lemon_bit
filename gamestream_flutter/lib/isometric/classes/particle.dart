import 'package:gamestream_flutter/gamestream/isometric/classes/src.dart';
import 'package:gamestream_flutter/packages/common/src.dart';
import 'package:lemon_math/src.dart';


/// x: 00 - 10
/// y: 11 - 20
/// z: 21 - 31
class Particle extends Position {

  var blownByWind = true;
  var frictionAir = 0.98;
  var wind = 0;
  var active = false;
  var delay = 0;
  var vx = 0.0;
  var vy = 0.0;
  var vz = 0.0;
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
  var nodeIndex = 0;
  var onscreen = false;

  var emissionColor = 0;
  var emissionIntensity = 0.0;
  var flash = true;
  var emitsLight = false;

  Particle({super.x, super.y, super.z, this.active = false});

  int get direction => IsometricDirection.fromRadian(rotation);

  double get duration01 {
    final durationTotal = this.durationTotal;
    return durationTotal <= 0 ? 0 : duration / durationTotal;
  }

  void deactivate(){
    active = false;
    duration = -1;
    durationTotal = -1;
    frame = 0;
    delay = 0;
    onscreen = false;
  }

  void setAngle({required double value, required double speed}){
    vx = adj(value, speed);
    vy = opp(value, speed);
  }

  void applyMotion(){
    x += vx;
    y += vy;
    z += vz;

    if (z < 0){
      z = 0;
    }

    final rotationVelocity = this.rotationVelocity;
    if (rotationVelocity != 0) {
      rotation = (rotation + rotationVelocity) % pi2;
    }

    final scaleVelocity = this.scaleVelocity;
    if (scaleVelocity != 0) {
      scale += scaleVelocity;
      if (scale < 0){
        scale = 0;
      }
    }
  }

  void applyAirFriction(){
    final frictionAir = this.frictionAir;
    vx *= frictionAir;
    vy *= frictionAir;
  }

  void applyGravity(){
    const gravity = 0.04;
    vz -= gravity * weight;
  }

  void applyFloorFriction(){
    const floorFriction = 0.9;
    const rotationFriction = 0.93;
    vx *= floorFriction;
    vy *= floorFriction;
    rotationVelocity *= rotationFriction;
  }

  @override
  String toString() =>
          '{'
          'x: ${x.toInt()}, '
          'y: ${y.toInt()}, '
          'z: ${z.toInt()}, '
          'active: $active, '
          'type: ${ParticleType.getName(type)}'
          '}';

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

  void update(IsometricParticles particles){

  }

  void addForce({
    required double speed,
    required double angle,
  }) {
    vx += adj(angle, speed);
    vy += opp(angle, speed);
  }

  void setSpeed(double angle, double speed){
    vx = adj(angle, speed);
    vy = opp(angle, speed);
  }
}

