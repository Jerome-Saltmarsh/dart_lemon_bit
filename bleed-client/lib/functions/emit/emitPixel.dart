import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

const _initialVelocityMin = 0.15;
const _initialVelocityMax = 0.25;
const _minDuration = 50;
const _maxDuration = 150;

void emitPixel({
  required double x,
  required double y
}) {
  Particle particle = getAvailableParticle();
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



  // particle.xv = giveOrTake(pi) * 0.1;
  // particle.yv = giveOrTake(pi) * 0.1;
  particle.zv = 0.01;
  particle.airFriction = 0.98;
  particle.hue = randomInt(0, totalHues);
}

const totalHues = 64;
