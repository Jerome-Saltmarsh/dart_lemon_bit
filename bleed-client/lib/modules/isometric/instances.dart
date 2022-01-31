
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/modules/modules.dart';

class IsometricInstances {
  final IsometricState state;
  IsometricInstances(this.state);

  Particle getAvailableParticle() {
    for (Particle particle in isometric.state.particles) {
      if (particle.active) continue;
      return particle;
    }
    return particle();
  }

  particle(){
    final newParticleInstance = Particle();
    isometric.state.particles.add(newParticleInstance);
    return newParticleInstance;
  }

}