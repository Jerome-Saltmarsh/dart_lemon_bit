import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/utils/list_util.dart';

import '../state.dart';
import 'updateParticle.dart';

// TODO Refactor
void updateParticles() {
  for (int i = 0; i < compiledGame.particles.length; i++) {
    if (compiledGame.particles[i].duration-- < 0) {
      compiledGame.particles.removeAt(i);
      i--;
      continue;
    }
  }

  for (Particle particle in compiledGame.particles) {
    updateParticle(particle);
  }

  sort(compiledGame.particles, _compareParticle);
}

int _compareParticle(Particle a) {
  return a.type.index;
}
