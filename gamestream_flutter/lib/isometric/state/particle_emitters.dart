
import 'package:gamestream_flutter/isometric/classes/particle_emitter.dart';

import 'particles.dart';

final particleEmitters = <ParticleEmitter>[];

void updateParticleEmitters(){
  for (final emitter in particleEmitters) {
    if (emitter.next-- > 0) continue;
    emitter.next = emitter.rate;
    final particle = getParticleInstance();
    particle.x = emitter.x;
    particle.y = emitter.y;
    emitter.emit(particle);
  }
}