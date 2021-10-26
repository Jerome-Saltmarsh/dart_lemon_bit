import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/state.dart';

Particle getDeactiveParticle() {
  for (Particle particle in compiledGame.particles) {
    if (particle.active) continue;
    return particle;
  }
  return null;
}
