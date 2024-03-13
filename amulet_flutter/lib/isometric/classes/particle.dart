import 'package:amulet_common/src.dart';
import 'package:amulet_flutter/isometric/components/isometric_particles.dart';
import 'package:amulet_flutter/isometric/classes/position.dart';
import 'package:lemon_math/src.dart';

class Particle extends Position {
  var sortOrderCached = 0.0;
  var blownByWind = true;
  var frictionAir = 0.98;
  var wind = 0;
  var deactivating = false;
  var vx = 0.0;
  var vy = 0.0;
  var vz = 0.0;
  var weight = 0.0;
  var duration = 0;
  var durationTotal = 0;
  var rotation = 0.0;
  var rotationVelocity = 0.0;
  var scale = 0.0;
  var scaleVelocity = 0.0;
  var type = 0;
  var bounciness = 0.0;
  // var deactiveOnNodeCollision = true;
  // var nodeCollidable = true;
  var animation = false;
  var nodeIndex = 0;
  var onscreen = false;

  var emissionColor = 0;
  var emissionIntensity = 0.0;
  var flash = true;
  var emitsLight = false;

  Particle({super.x, super.y, super.z});

  int get direction => IsometricDirection.fromRadian(rotation);

  double get duration01 {
    final durationTotal = this.durationTotal;
    return durationTotal <= 0 ? 0 : duration / durationTotal;
  }

  void deactivate(){
    duration = -1;
    durationTotal = -1;
    onscreen = false;
    deactivating = true;
  }

  void setAngle({required double value, required double speed}){
    vx = adj(value, speed);
    vy = opp(value, speed);
  }

  void applyMotion(){
    x += vx;
    y += vy;

    final vz = this.vz;

    if (vz != 0){
      final z = this.z + vz;
      this.z = z;
      if (z < 0){
        this.z = 0;
      }
    }

    final scaleVelocity = this.scaleVelocity;
    if (scaleVelocity != 0) {
      scale += scaleVelocity;
      if (scale < 0){
        scale = 0;
      }
    }
  }

  void applyRotationVelocity() {
    final rotationVelocity = this.rotationVelocity;
    if (rotationVelocity != 0) {
      rotation = (rotation + rotationVelocity) % pi2;
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
          'deactivating: $deactivating, '
          'type: ${ParticleType.getName(type)}'
          '}';

  static int compare(Particle a, Particle b) {

    final thisRenderOrder = a.sortOrderCached;
    final thatRenderOrder = b.sortOrderCached;

    if (thisRenderOrder < thatRenderOrder)
      return -1;

    if (thisRenderOrder > thatRenderOrder)
      return 1;

    return 0;
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

