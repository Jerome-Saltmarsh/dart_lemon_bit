
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_whisp.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_particles.dart';
import 'package:gamestream_flutter/packages/common/src/particle_type.dart';
import 'package:lemon_math/src.dart';

class ParticleGlow extends ParticleWhisp {

  var _i = 0.0;
  var _iDirection = 0.02;

  var nextSpawnTrail = 0;

  ParticleGlow({
    required super.x,
    required super.y,
    required super.z,
    required int color,
  }) {
    emitsLight = true;
    blownByWind = false;
    type = ParticleType.Glow;
    emissionColor = color;
    _i = random.nextDouble();
    movementSpeed = 0.7;
  }

  @override
  void update(IsometricParticles particles) {
    updateMovement();

    _i += _iDirection;
    if (_i > 1.0 || _i < 0){
      _iDirection = -_iDirection;
      _i = _i.clamp(0, 1);
    }
    emissionIntensity = interpolate(_i, 0.2, 0.7);
    scale =  interpolate(_i, 0.5, 1.0);

    if (nextSpawnTrail-- <= 0){
      particles.spawnTrail(x, y, z, color: emissionColor);
      nextSpawnTrail = 15;
    }
  }
}