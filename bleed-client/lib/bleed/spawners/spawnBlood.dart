import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/enums/ParticleType.dart';
import 'package:flutter_game_engine/bleed/utils.dart';

import '../state.dart';

void spawnBlood(double x, double y, double z, {double xv = 0, double yv = 0, double zv = 0 }){
  particles.add(Particle(
      ParticleType.Blood,
      x,
      y,
      z,
      xv,
      yv,
      zv,
      weight: 0.1,
      duration: randomInt(90, 150),
      rotation: 0,
      rotationV: 0,
      scale: 1,
      scaleV: 0.0075
  ));
}