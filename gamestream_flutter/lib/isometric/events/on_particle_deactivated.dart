

import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';

void onParticleDeactivated(Particle particle) {
  if (particle.type == ParticleType.Fire){
    print("Fire particle deactivated");
  }
}