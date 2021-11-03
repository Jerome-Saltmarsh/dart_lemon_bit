import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/state/game.dart';

Particle getDeactiveParticle() {
  for (Particle particle in game.particles) {
    if (particle.active) continue;
    return particle;
  }
  return null;
}
