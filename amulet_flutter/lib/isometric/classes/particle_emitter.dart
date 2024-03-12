

import 'package:amulet_flutter/isometric/components/isometric_particles.dart';

import 'particle.dart';

class ParticleEmitter extends Particle {

  var nextEmission = 0;
  var emissionRate = 5;
  var emissionParticleType = 0;

  @override
  void update(IsometricParticles particles) {
    if (nextEmission-- <= 0){
      nextEmission = emissionRate;

      particles.spawnParticle(
          particleType: emissionParticleType,
          x: x,
          y: y,
          z: z,
      );
    }
  }
}