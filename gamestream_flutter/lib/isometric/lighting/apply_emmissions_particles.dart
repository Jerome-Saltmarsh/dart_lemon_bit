
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_particle_emissions.dart';

void applyEmissionsParticles(){
  for (var i = 0; i < Game.totalParticles; i++){
    applyParticleEmission(Game.particles[i]);
  }
}