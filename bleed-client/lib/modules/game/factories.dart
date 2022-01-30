
import 'package:lemon_math/give_or_take.dart';
import 'dart:math';

import 'package:bleed_client/state/particleSettings.dart';
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