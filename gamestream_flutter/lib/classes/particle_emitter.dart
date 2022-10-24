

import 'package:bleed_common/library.dart';

import 'particle.dart';
import 'vector3.dart';

typedef Particle GetParticle();

class ParticleEmitter extends Vector3 {
  var next = 0;
  int rate;
  Function(Particle particle) emit;

  ParticleEmitter({
    required this.rate,
    required this.emit,
    required int z,
    required int row,
    required int column
  }) {
    indexZ = z;
    indexRow = row;
    indexColumn = column;
    y += tileHeightHalf;
  }
}

