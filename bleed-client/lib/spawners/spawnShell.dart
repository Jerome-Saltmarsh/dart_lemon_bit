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
    xv: giveOrTake(pi),
    yv: giveOrTake(pi),
    zv: 0.1,
    weight: 1,
    duration: 280,
    rotation: 0,
    rotationV: 0,
    scale: 1,
  );
}
