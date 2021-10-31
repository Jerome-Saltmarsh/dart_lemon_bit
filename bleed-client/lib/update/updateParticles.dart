import 'package:bleed_client/classes/Particle.dart';

import '../state.dart';
import '../update/updateParticle.dart';

bool _sort = true;

void updateParticles() {
  for (Particle particle in compiledGame.particles) {
    if (!particle.active) continue;
    updateParticle(particle);
  }

  // _sort = !_sort;
  // if (_sort) {
  //   sort(compiledGame.particles, _compareParticle);
  // }
}

int _compareParticle(Particle a) {
  if (!a.active) return -1;
  return a.type.index;
}
