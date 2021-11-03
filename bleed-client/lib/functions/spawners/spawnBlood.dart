import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/utils.dart';

import 'spawnParticle.dart';


void spawnBlood(double x, double y, double z,
    {double xv = 0, double yv = 0, double zv = 0}) {
  spawnParticle(
      type: ParticleType.Blood,
      x: x,
      y: y,
      z: z,
      xv: xv,
      yv: yv,
      zv: zv,
      weight: 0.1,
      duration: randomInt(90, 170),
      rotation: 0,
      rotationV: 0,
      scale: 1,
      scaleV: 0.0085,
      bounciness: 0);
}
