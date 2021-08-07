import 'dart:math';

import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/enums/ParticleType.dart';

import '../maths.dart';
import '../state.dart';

void spawnShell(double x, double y){
  particles.add(Particle(
      ParticleType.Shell,
      x,
      y,
      0.4,
      giveOrTake(pi),
      giveOrTake(pi),
      0.1,
      weight: 1,
      duration: 280,
      rotation: 0,
      rotationV: 0,
      scale: 1,
  ));
}