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
    emission_col = hsvToColor(
        hue: interpolate(start: GameNodes.ambient_hue, end: emission_hue , t: emission_intensity),
        saturation: interpolate(start: GameNodes.ambient_sat, end: emission_sat, t: emission_intensity),
        value: interpolate(start: GameNodes.ambient_val, end: emission_val, t: emission_intensity),
        opacity: interpolate(start: GameNodes.ambient_alp, end: emission_alp, t: emission_intensity),
    );
  }
}

class EmissionType {
  static const None = 0;
  static const Ambient = 1;
  static const Color = 2;
}