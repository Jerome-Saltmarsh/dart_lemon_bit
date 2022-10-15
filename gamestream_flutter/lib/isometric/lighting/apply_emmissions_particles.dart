
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/lighting/apply_particle_emissions.dart';

void applyEmissionsParticles(){
  for (var i = 0; i < GameState.totalParticles; i++){
    applyParticleEmission(GameState.particles[i]);
  }
}