

import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';

import 'apply_vector_emission.dart';

void applyParticleEmission(Particle particle){
  if (particle.type == ParticleType.Orb_Shard){
    if (particle.duration > 12){
      return applyVector3Emission(particle, maxBrightness: Shade.Very_Bright);
    }
    if (particle.duration > 9){
      return applyVector3Emission(particle, maxBrightness: Shade.Bright);
    }
    if (particle.duration > 6){
      return applyVector3Emission(particle, maxBrightness: Shade.Medium);
    }
    if (particle.duration > 3) {
      return applyVector3Emission(particle, maxBrightness: Shade.Medium);
    }
    return applyVector3Emission(particle, maxBrightness: Shade.Dark);
  }
}