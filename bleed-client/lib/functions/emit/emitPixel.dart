import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:lemon_math/random_between.dart';

void emitPixel({double x, double y}) {
  Particle particle = getAvailableParticle();
  particle.active = true;
  particle.type = ParticleType.Pixel;
  particle.duration = 150;
  particle.z = 0.5;
  particle.weight = 0;
  particle.scale = 0.25;
  particle.scaleV = 0.0025;
  particle.rotation = 0;
  particle.rotationV = 0;
  particle.xv = randomBetween(0, -pi * 0.025);
  particle.yv = randomBetween(0, pi * 0.025);
  // particle.xv = giveOrTake(pi) * 0.1;
  // particle.yv = giveOrTake(pi) * 0.1;
  particle.zv = 0.01;
  particle.airFriction = 0.98;
  // particle.hue = randomBetween(0, 65).toInt();
  particle.hue = 9;
}
