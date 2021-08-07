import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/enums/ParticleType.dart';
import 'package:flutter_game_engine/bleed/state.dart';

void spawnSmoke(double x, double y, double z, {double xv = 0, double yv = 0 }){
  particles.add(Particle(
    ParticleType.Smoke,
    x,
    y,
    z,
    xv,
    yv,
    -0.25,
    weight: 0,
    duration: 120,
    rotation: 0,
    rotationV: 0,
    scale: 0.1,
    scaleV: 1.02
  ));
}