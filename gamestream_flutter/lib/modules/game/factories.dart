import 'dart:math';

import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/mappers/mapParticleToSrc.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_math/library.dart';

class GameFactories {

  static const totalHues = 64;
  static const _initialVelocityMin = 0.15;
  static const _initialVelocityMax = 0.25;
  static const _minDuration = 50;
  static const _maxDuration = 150;
  static const  mystMaxVelocity = 0.1;
  static const  mystPositionRange = 50;

  void emitPixel({
    required double x,
    required double y
  }) {
    final particle = isometric.spawn.getAvailableParticle();
    particle.x = x;
    particle.y = y;
    particle.type = ParticleType.Pixel;
    particle.duration = randomInt(_minDuration, _maxDuration);
    particle.z = 0.5;
    particle.weight = 0;
    particle.scale = 0.33;
    particle.scaleV = 0.0025;
    particle.rotation = 0;
    particle.rotationVelocity = 0;
    particle.airFriction = 0.95;
    particle.xv = giveOrTake(pi * randomBetween(_initialVelocityMin, _initialVelocityMax));
    particle.yv = giveOrTake(pi * randomBetween(_initialVelocityMin, _initialVelocityMax));
    particle.zv = 0.01;
    particle.airFriction = 0.98;
    particle.hue = randomInt(0, totalHues);
  }


  void emitMyst(Particle particle) {
    particle.type = ParticleType.Myst;
    particle.duration = mystDuration;
    particle.x += giveOrTake(mystPositionRange);
    particle.y += giveOrTake(mystPositionRange);
    particle.z = 0.5;
    particle.weight = 0;
    particle.scale = 1;
    particle.scaleV = 0;
    particle.rotation = 0;
    particle.rotationVelocity = 0;
    particle.bounciness = 0;
    particle.airFriction = 1.0;
    particle.xv = giveOrTake(pi * mystMaxVelocity);
    particle.yv = giveOrTake(pi * mystMaxVelocity);
    particle.zv = 0.0;
    particle.casteShadow = false;
  }
}

void emitSmoke(Particle particle){
  print("emit smoke");
  particle.type = ParticleType.Smoke;
  particle.duration = randomBetween(100, 150).toInt();
  particle.z = 0;
  particle.weight = 0;
  particle.scale = 1;
  particle.scaleV = 0;
  particle.rotation = 0;
  particle.rotationVelocity = 0;
  particle.bounciness = 0;
  particle.xv = randomBetween(0, -pi * 0.1);
  particle.yv = randomBetween(0, pi * 0.1);
  particle.zv = 0.01;
  particle.airFriction = 0.98;
}
