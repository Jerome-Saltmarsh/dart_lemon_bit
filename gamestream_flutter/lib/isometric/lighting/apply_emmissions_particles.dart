
import 'package:gamestream_flutter/isometric/lighting/apply_particle_emissions.dart';
import 'package:gamestream_flutter/isometric/particles.dart';

void applyEmissionsParticles(){
  for (var i = 0; i < totalParticles; i++){
    applyParticleEmission(particles[i]);
  }
}