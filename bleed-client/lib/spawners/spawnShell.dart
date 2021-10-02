import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/spawners/spawnParticle.dart';

import '../maths.dart';
import '../state.dart';

void spawnShell(double x, double y) {
  spawnParticle(
    type: ParticleType.Shell,
    x: x,
    y: y,
    z: 0.4,
    xv: giveOrTake(pi) * 0.5,
    yv: giveOrTake(pi) * 0.5,
    zv: 0.05,
    weight: 0.2,
    duration: 100,
    rotation: 0,
    rotationV: 0,
    scale: 1,
  );
}
