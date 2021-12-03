import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomInt.dart';
import 'package:lemon_math/random_between.dart';

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
      duration: randomInt(150, 200),
      scale: randomBetween(0.6, 1.25),
      scaleV: 0);
}
