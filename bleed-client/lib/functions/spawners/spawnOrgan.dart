import 'dart:math';

import 'package:bleed_client/enums/ParticleType.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import 'spawnParticle.dart';

void spawnOrgan(double x, double y, double z, {double xv = 0, double yv = 0}) {
  spawnParticle(
      type: ParticleType.Organ,
      x: x,
      y: y,
      z: z,
      xv: xv,
      yv: yv,
      zv: randomBetween(0, 0.03),
      weight: 0.25,
      duration: randomInt(90, 150),
      rotation: giveOrTake(pi),
      rotationV: giveOrTake(0.25),
      scale: 1,
      scaleV: 0);
}
