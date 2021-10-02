import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/spawners/spawnParticle.dart';

import '../state.dart';

void spawnSmoke(double x, double y, double z, {double xv = 0, double yv = 0}) {
  spawnParticle(
      type: ParticleType.Smoke,
      x: x,
      y: y,
      z: z,
      xv: xv,
      yv: yv,
      zv: 0.015,
      weight: 0.0,
      duration: 120,
      rotation: 0,
      rotationV: 0,
      scale: 0.2,
      scaleV: 0.005);
}
