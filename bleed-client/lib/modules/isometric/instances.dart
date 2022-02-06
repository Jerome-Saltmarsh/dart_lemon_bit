
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/modules/isometric/state.dart';

class IsometricInstances {
  final IsometricState state;
  IsometricInstances(this.state);

  Particle getAvailableParticle() {
    for (Particle particle in state.particles) {
      if (particle.active) continue;
      return particle;
    }
    final instance = Particle();
    state.particles.add(instance);
    return instance;
  }
}
