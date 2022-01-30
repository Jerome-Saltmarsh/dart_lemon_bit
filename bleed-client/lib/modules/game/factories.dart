
import 'dart:math';

import 'package:lemon_math/random_between.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';

class GameFactories {
  void buildParticleSmoke(Particle particle){
    particle.type = ParticleType.Smoke;
    particle.duration = randomBetween(100, 150).toInt();
    particle.z = 0;
    particle.weight = 0;
    particle.scale = 1;
    particle.scaleV = 0;
    particle.rotation = 0;
    particle.rotationV = 0;
    particle.bounciness = 0;
    particle.xv = randomBetween(0, -pi * 0.1);
    particle.yv = randomBetween(0, pi * 0.1);
    particle.zv = 0.01;
    particle.airFriction = 0.98;
  }
}