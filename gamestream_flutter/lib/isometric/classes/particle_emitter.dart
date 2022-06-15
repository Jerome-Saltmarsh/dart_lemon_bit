

import 'package:gamestream_flutter/isometric/classes/particle.dart';

typedef Particle GetParticle();

class ParticleEmitter {
  var x = 0.0;
  var y = 0.0;
  var next = 0;
  int rate;
  Function(Particle particle) emit;

  ParticleEmitter({
    required this.x,
    required this.y,
    required this.rate,
    required this.emit
  });
}

