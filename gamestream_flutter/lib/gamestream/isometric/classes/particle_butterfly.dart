

import 'package:gamestream_flutter/gamestream/isometric/classes/particle_whisp.dart';
import 'package:gamestream_flutter/packages/common/src/particle_type.dart';

class ParticleButterfly extends ParticleWhisp {
  ParticleButterfly({required super.x, required super.y, required super.z}) {
    type = ParticleType.Butterfly;
    blownByWind = false;
  }

  @override
  void update() {
    super.update();
    rotation = movementAngle;
  }
}