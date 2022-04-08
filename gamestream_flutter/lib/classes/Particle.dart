import 'dart:math';

import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/opposite.dart';
import 'package:lemon_math/Vector2.dart';

class Particle extends Vector2 {
  double z = 0;
  double xv = 0;
  double yv = 0;
  double zv = 0;
  double weight = 0;
  int duration = 0;
  double rotation = 0;
  double rotationV = 0;
  double scale = 0;
  double scaleV = 0;
  int type = ParticleType.Zombie_Head;
  double bounciness = 0;
  double airFriction = 0.98;
  bool foreground = false;
  int hue = 0;
  bool hasShadow = false;
  double size = 0;

  Particle? next;

  bool get active => duration > 0;

  Particle():super(0,0);

  void setAngle({required double value, required double speed}){
    xv = adjacent(value, speed);
    yv = opposite(value, speed);
  }

  void updateMotion(){
    const pi2 = pi * 2;
    z += zv;
    x += xv;
    y += yv;
    if (z < 0){
      z = 0;
    }
    rotation = (rotation + rotationV) % pi2;
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

  void applyLimits(){
    if (scale < 0) {
      scale = 0;
    }
    if (z <= 0) {
      z = 0;
    }
  }
}

