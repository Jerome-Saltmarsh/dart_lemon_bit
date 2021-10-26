import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/utils.dart';

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
      rotation: 0,
      rotationV: 0,
      scale: 1,
      scaleV: 0);
}
