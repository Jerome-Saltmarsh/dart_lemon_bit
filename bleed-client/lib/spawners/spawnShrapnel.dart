import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/spawners/spawnParticle.dart';
import 'package:bleed_client/utils.dart';

void spawnShrapnel(double x, double y) {
  spawnParticle(
      type: ParticleType.Shrapnel,
      x: x,
      y: y,
      z: 0,
      xv: giveOrTake(2),
      yv: giveOrTake(2),
      zv: randomBetween(0.1, 0.4),
      weight: 0.5,
      duration: randomInt(400, 600),
      scale: randomBetween(0.6, 1.25),
      scaleV: 0);
}
