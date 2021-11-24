import 'dart:math';

import 'package:bleed_client/enums/ParticleType.dart';
import 'package:flutter/material.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import 'spawnParticle.dart';


void spawnArm(double x, double y, double z, {double xv = 0, double yv = 0}) {
  spawnParticle(
      type: ParticleType.Arm,
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
      scale: 0.5,
      scaleV: 0);
}
