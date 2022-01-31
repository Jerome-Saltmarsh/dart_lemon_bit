import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:lemon_math/give_or_take.dart';
import 'dart:math';

import 'package:bleed_client/state/particleSettings.dart';
import 'package:lemon_math/random_between.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';

class GameFactories {

  static const totalHues = 64;
  static const _initialVelocityMin = 0.15;
  static const _initialVelocityMax = 0.25;
  static const _minDuration = 50;
  static const _maxDuration = 150;

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

  void emitPixel({
    required double x,
    required double y
  }) {
    Particle particle = isometric.instances.getAvailableParticle();
    particle.x = x;
    particle.y = y;
    particle.active = true;
    particle.type = ParticleType.Pixel;
    particle.duration = randomInt(_minDuration, _maxDuration);
    particle.z = 0.5;
    particle.weight = 0;
    particle.scale = 0.33;
    particle.scaleV = 0.0025;
    particle.rotation = 0;
    particle.rotationV = 0;
    particle.airFriction = 0.95;
    particle.xv = giveOrTake(pi * randomBetween(_initialVelocityMin, _initialVelocityMax));
    particle.yv = giveOrTake(pi * randomBetween(_initialVelocityMin, _initialVelocityMax));
    particle.zv = 0.01;
    particle.airFriction = 0.98;
    particle.hue = randomInt(0, totalHues);
  }


  void emitMyst(Particle particle) {
    particle.active = true;
    particle.type = ParticleType.Myst;
    particle.duration = particleSettings.mystDuration;
    particle.x += giveOrTake(particleSettings.mystPositionRange);
    particle.y += giveOrTake(particleSettings.mystPositionRange);
    particle.z = 0.25;
    particle.weight = 0;
    particle.scale = 1;
    particle.scaleV = 0;
    particle.rotation = 0;
    particle.rotationV = 0;
    particle.bounciness = 0;
    particle.airFriction = 1.0;
    particle.xv = giveOrTake(pi * particleSettings.mystMaxVelocity);
    particle.yv = giveOrTake(pi * particleSettings.mystMaxVelocity);
    particle.zv = 0.0;
  }

}