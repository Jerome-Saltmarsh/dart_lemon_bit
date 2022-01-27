import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/state/game.dart';

import '../update/updateParticle.dart';

void updateParticles() {
  for (Particle particle in isometric.state.particles) {
    if (!particle.active) continue;
    updateParticle(particle);
  }
}

