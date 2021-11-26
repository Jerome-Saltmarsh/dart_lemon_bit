import 'dart:math';

import 'package:bleed_client/enums/ParticleType.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import 'spawnParticle.dart';


void spawnZombieHead(double x, double y, double z, {double xv = 0, double yv = 0}) {
  spawnParticle(
    type: ParticleType.Zombie_Head,
    x: x,
    y: y,
    z: z,
    xv: xv,
    yv: yv,
    zv: randomBetween(0.04, 0.08),
    weight: 0.15,
    duration: randomInt(90, 150),
    rotation: giveOrTake(pi),
    rotationV: 0.05,
    scale: 0.75,
    scaleV: 0,
  );
}
