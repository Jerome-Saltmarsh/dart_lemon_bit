
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/instances/game.dart';

void spawnSmoke(double x, double y, double z, {double xv = 0, double yv = 0 }){
  compiledGame.particles.add(Particle(
    ParticleType.Smoke,
    x,
    y,
    z,
    xv,
    yv,
    0.015,
    weight: 0.0,
    duration: 120,
    rotation: 0,
    rotationV: 0,
    scale: 0.2,
    scaleV: 0.005
  ));
}