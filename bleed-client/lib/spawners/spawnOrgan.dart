
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/instances/game.dart';

import '../maths.dart';
import '../utils.dart';

void spawnOrgan(double x, double y, double z, {double xv = 0, double yv = 0 }){
  compiledGame.particles.add(Particle(
      ParticleType.Organ,
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