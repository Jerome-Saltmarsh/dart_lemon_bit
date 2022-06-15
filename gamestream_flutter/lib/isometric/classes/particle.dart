import 'dart:math';

import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:gamestream_flutter/isometric/render/render_particle.dart';
import 'package:lemon_math/library.dart';

class Particle extends Vector3 {
  double xv = 0;
  double yv = 0;
  double zv = 0;
  double weight = 0;
  int duration = 0;
  double rotation = 0;
  double rotationVelocity = 0;
  double scale = 0;
  double scaleV = 0;
  int type = ParticleType.Zombie_Head;
  double bounciness = 0;
  double airFriction = 0.98;
  int hue = 0;
  bool casteShadow = false;
  double size = 0;

  Particle? next;

  bool get active => duration > 0;

  bool get bleeds {
     if (type == ParticleType.Blood) return false;
     if (type == ParticleType.Zombie_Head) return true;
     if (type == ParticleType.Organ) return true;
     if (type == ParticleType.Arm) return true;
     if (type == ParticleType.Leg) return true;
     return false;
  }

  Particle():super(0, 0, 0);

  double get speed => sqrt(xv * xv + yv * yv);

  double get renderScale => (1.0 + (z * 0.4)) * scale;

  void setAngle({required double value, required double speed}){
    xv = getAdjacent(value, speed);
    yv = getOpposite(value, speed);
  }

  void updateMotion(){
    z += zv;
    x += xv;
    y += yv;
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

  void render(){
    switch (type) {
      case ParticleType.Smoke:
        return renderSmoke(x: renderX, y: renderY, scale: renderScale);
      case ParticleType.Orb_Shard:
        return renderOrbShard(x: renderX, y: renderY, scale: renderScale);
      case ParticleType.Shrapnel:
        return renderShrapnel(x: renderX, y: renderY, scale: renderScale);
      case ParticleType.FireYellow:
        return renderFireYellow(x: renderX, y: renderY, scale: renderScale);
      case ParticleType.Flame:
        // return renderFlame(value);
      default:
        break;
    }
  }
}

