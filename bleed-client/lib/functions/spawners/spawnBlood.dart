import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:lemon_math/randomInt.dart';

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
      scale: 0.4,
      scaleV: 0,
      bounciness: 0);
}
