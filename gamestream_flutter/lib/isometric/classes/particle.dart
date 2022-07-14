import 'dart:math';

import 'package:bleed_common/Direction.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:lemon_math/library.dart';

class Particle extends Vector3 {
  var xv = 0.0;
  var yv = 0.0;
  var zv = 0.0;
  var weight = 0.0;
  var duration = 0;
  var rotation = 0.0;
  var rotationVelocity = 0.0;
  var scale = 0.0;
  var scaleV = 0.0;
  var type = 0;
  var bounciness = 0.0;
  var airFriction = 0.98;
  var hue = 0;
  var casteShadow = false;

  bool get active => duration > 0;

  int get direction => convertAngleToDirection(rotation);

  void deactivate(){
    duration = -1;
  }

  bool get bleeds {
     if (type == ParticleType.Blood) return false;
     if (type == ParticleType.Zombie_Head) return true;
     if (type == ParticleType.Zombie_Torso) return true;
     if (type == ParticleType.Zombie_Arm) return true;
     if (type == ParticleType.Zombie_leg) return true;
     return false;
  }

  double get speed => sqrt(xv * xv + yv * yv);

  void setAngle({required double value, required double speed}){
    xv = getAdjacent(value, speed);
    yv = getOpposite(value, speed);
  }

  void updateMotion(){
    x += xv;
    y += yv;
    z += zv;
    if (z < 0){
      z = 0;
    }
    rotation = clampAngle(rotation + rotationVelocity);
    scale += scaleV;
    if (scale < 0){
      scale = 0;
    }
  }

  void applyAirFriction(){
    const gravity = 0.04;
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

