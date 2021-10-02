import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/utils/list_util.dart';

import '../state.dart';
import 'updateParticle.dart';

void updateParticles() {
  for (Particle particle in compiledGame.particles) {
    if (!particle.active) continue;
    updateParticle(particle);
  }

  sort(compiledGame.particles, _compareParticle);
}

int _compareParticle(Particle a) {
  if (!a.active) return -1;
  return a.type.index;
}
