
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_whisp.dart';
import 'package:lemon_math/src.dart';

class ParticleGlow extends ParticleWhisp {

  var _i = 0.0;
  var _iDirection = 0.02;

  ParticleGlow({
    required super.x,
    required super.y,
    required super.z,
  }) {
    emitsLight = true;
    blownByWind = false;
  }

  @override
  void update() {
    super.update();
    _i += _iDirection;
    if (_i > 1.0 || _i < 0){
      _iDirection = -_iDirection;
      _i = _i.clamp(0, 1);
    }
    emissionIntensity = interpolate(_i, 0.2, 0.7);
  }
}