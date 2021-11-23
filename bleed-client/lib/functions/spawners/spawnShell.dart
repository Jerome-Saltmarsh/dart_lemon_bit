import 'dart:math';

import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:lemon_math/angle.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/piHalf.dart';


void spawnShell(double x, double y) {

  double xv = giveOrTake(pi) * 0.5;
  double yv = giveOrTake(pi) * 0.5;
  double rotation = angle(xv, yv) + piHalf;
  spawnParticle(
    type: ParticleType.Shell,
    x: x,
    y: y,
    z: 0.4,
    xv: xv,
    yv: yv,
    zv: 0.05,
    weight: 0.2,
    duration: 100,
    rotation: rotation,
    rotationV: 0,
    scale: 0.25,
  );
}
