

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

  if (particle.type == ParticleType.Light_Emission){

    if (particle.duration > 18){
      return applyVector3Emission(particle, maxBrightness: Shade.Very_Very_Dark);
    }
    if (particle.duration > 17){
      return applyVector3Emission(particle, maxBrightness: Shade.Very_Dark);
    }
    if (particle.duration > 16){
      return applyVector3Emission(particle, maxBrightness: Shade.Dark);
    }
    if (particle.duration > 15){
      return applyVector3Emission(particle, maxBrightness: Shade.Medium);
    }
    if (particle.duration > 14){
      return applyVector3Emission(particle, maxBrightness: Shade.Bright);
    }
    if (particle.duration > 13){
      return applyVector3Emission(particle, maxBrightness: Shade.Very_Bright);
    }
    if (particle.duration > 9){
      return applyVector3Emission(particle, maxBrightness: Shade.Bright);
    }
    if (particle.duration > 7){
      return applyVector3Emission(particle, maxBrightness: Shade.Medium);
    }
    if (particle.duration > 5) {
      return applyVector3Emission(particle, maxBrightness: Shade.Dark);
    }
    if (particle.duration > 3) {
      return applyVector3Emission(particle, maxBrightness: Shade.Very_Dark);
    }
    return applyVector3Emission(particle, maxBrightness: Shade.Very_Very_Dark);
  }
}