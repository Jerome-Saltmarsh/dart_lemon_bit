import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/state/game.dart';

import '../update/updateParticle.dart';

void updateParticles() {
  for (Particle particle in game.particles) {
    if (!particle.active) continue;
    updateParticle(particle);
  }
}

