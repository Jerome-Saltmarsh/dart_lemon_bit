import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

void emitPixel({double x, double y}) {
  Particle particle = getAvailableParticle();
  particle.x = x;
  particle.y = y;
  particle.active = true;
  particle.type = ParticleType.Pixel;
  particle.duration = 150;
  particle.z = 0.5;
  particle.weight = 0;
  particle.scale = 1;
  particle.scaleV = 0.0025;
  particle.rotation = 0;
  particle.rotationV = 0;
  particle.xv = randomBetween(0, -pi * 0.025);
  particle.yv = randomBetween(0, pi * 0.025);
  // particle.xv = giveOrTake(pi) * 0.1;
  // particle.yv = giveOrTake(pi) * 0.1;
  particle.zv = 0.01;
  particle.airFriction = 0.98;
  particle.hue = randomInt(0, totalHues);
}

const totalHues = 64;
