import 'dart:math';

import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

import 'spawnParticle.dart';


void spawnHead(double x, double y, double z, {double xv = 0, double yv = 0}) {
  spawnParticle(
    type: ParticleType.Human_Head,
    x: x,
    y: y,
    z: z,
    xv: xv,
    yv: yv,
    zv: randomBetween(0, 0.03),
    weight: 0.25,
    duration: randomInt(90, 150),
    rotation: giveOrTake(pi),
    rotationV: giveOrTake(10),
    scale: 1,
    scaleV: 0,
  );
}
