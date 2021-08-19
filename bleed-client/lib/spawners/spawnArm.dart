
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/instances/game.dart';

import '../maths.dart';
import '../utils.dart';

void spawnArm(double x, double y, double z, {double xv = 0, double yv = 0 }){
  game.particles.add(Particle(
      ParticleType.Arm,
      x,
      y,
      z,
      xv,
      yv,
      randomBetween(0, 0.03),
      weight: 0.25,
      duration: randomInt(90, 150),
      rotation: 0,
      rotationV: 0,
      scale: 1,
      scaleV: 0
  ));
}