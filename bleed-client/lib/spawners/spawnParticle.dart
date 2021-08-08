import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';

import '../maths.dart';
import '../state.dart';

void spawnParticle(ParticleType type, double x, double y, double z, double xv, double yv, double zv, double weight, int duration, double scale, double scaleV){
  particles.add(Particle(
    type,
    x,
    y,
    z,
    xv,
    yv,
    zv,
    weight: weight,
    duration: duration,
    rotation: 0,
    rotationV: 0,
    scale: scale,
    scaleV: scaleV
  ));
}