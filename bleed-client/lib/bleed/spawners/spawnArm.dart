
import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/enums/ParticleType.dart';
import 'package:flutter_game_engine/bleed/maths.dart';
import 'package:flutter_game_engine/bleed/utils.dart';

import '../state.dart';

void spawnArm(double x, double y, double z, {double xv = 0, double yv = 0 }){
  particles.add(Particle(
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