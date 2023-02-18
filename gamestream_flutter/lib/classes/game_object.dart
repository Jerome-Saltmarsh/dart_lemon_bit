import 'package:gamestream_flutter/functions/hsv_to_color.dart';
import 'package:gamestream_flutter/library.dart';

class GameObject extends Vector3 {
  var id = 0;
  var type = 0;
  var active = false;
  var emission_type = EmissionType.None;
  var emission_hue = 0;
  var emission_sat = 0;
  var emission_val = 0;
  var emission_alp = 0;
  var emission_col = 0;
  var _emission_intensity = 1.0;

  double get emission_intensity => _emission_intensity;

  set emission_intensity(double value){
     final clamped = clamp01(value);
     if (_emission_intensity == clamped) return;
     _emission_intensity = value;
     refreshEmissionColor();
  }

  void refreshEmissionColor(){
    emission_col = hsvToColor4(
        hue: Engine.linerInterpolationInt(GameNodes.ambient_hue, emission_hue , emission_intensity),
        saturation: Engine.linerInterpolationInt(GameNodes.ambient_sat, emission_sat, emission_intensity),
        value: Engine.linerInterpolationInt(GameNodes.ambient_val, emission_val, emission_intensity),
        opacity: Engine.linerInterpolationInt(GameNodes.ambient_alp, emission_alp, emission_intensity),
    );
  }
}

class EmissionType {
  static const None = 0;
  static const Ambient = 1;
  static const Color = 2;
}