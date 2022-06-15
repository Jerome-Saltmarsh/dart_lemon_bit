
import 'dart:math';

import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:gamestream_flutter/mappers/mapParticleToSrc.dart';
import 'package:lemon_math/library.dart';

import '../modules.dart';

void emitParticlePixel({
  required double x,
  required double y
}) {
  const initialVelocityMin = 0.15;
  const initialVelocityMax = 0.25;
  final particle = isometric.spawn.getAvailableParticle();
  particle.x = x;
  particle.y = y;
  particle.type = ParticleType.Pixel;
  particle.duration = randomInt(50, 150);
  particle.z = 0.5;
  particle.weight = 0;
  particle.scale = 0.33;
  particle.scaleV = 0.0025;
  particle.rotation = 0;
  particle.rotationVelocity = 0;
  particle.airFriction = 0.95;
  particle.xv = giveOrTake(pi * randomBetween(initialVelocityMin, initialVelocityMax));
  particle.yv = giveOrTake(pi * randomBetween(initialVelocityMin, initialVelocityMax));
  particle.zv = 0.01;
  particle.airFriction = 0.98;
  particle.hue = randomInt(0, 64);
}

void emitMyst(Particle particle) {
  const velocity = 0.1;
  const range = 50;
  particle.type = ParticleType.Myst;
  particle.duration = mystDuration;
  particle.x += giveOrTake(range);
  particle.y += giveOrTake(range);
  particle.z = 0.5;
  particle.weight = 0;
  particle.scale = 1;
  particle.scaleV = 0;
  particle.rotation = 0;
  particle.rotationVelocity = 0;
  particle.bounciness = 0;
  particle.airFriction = 1.0;
  particle.xv = giveOrTake(pi * velocity);
  particle.yv = giveOrTake(pi * velocity);
  particle.zv = 0.0;
  particle.casteShadow = false;
}

void emitSmoke(Particle particle) {
  particle.type = ParticleType.Smoke;
  particle.duration = randomBetween(100, 150).toInt();
  particle.z = 1;
  particle.weight = 0;
  particle.scale = 0.15;
  particle.scaleV = 0.001;
  particle.rotation = 0;
  particle.rotationVelocity = 0;
  particle.bounciness = 0;
  particle.xv = randomBetween(0, -pi * 0.1);
  particle.yv = randomBetween(0, pi * 0.1);
  particle.zv = 0.025;
  particle.airFriction = 0.99;
}
