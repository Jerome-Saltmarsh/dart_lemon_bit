
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_whisp.dart';

class ParticleGlow extends ParticleWhisp {

  ParticleGlow({
    required super.x,
    required super.y,
    required super.z,
  }) {
    emitsLight = true;
    // emissionColor = colors.
    // intensity: particle.emissionIntensity,
  }

}