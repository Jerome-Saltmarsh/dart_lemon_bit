import 'package:gamestream_flutter/library.dart';

class GameObjectEmissionController {

  final GameObject gameObject;
  var emission_intensity_interpolation = 1.0;
  var intensity_start = 0.0;
  var intensity_end = 0.0;

  GameObjectEmissionController(this.gameObject);


}

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
  var emission_intensity_start = 0.15;
  var emission_intensity_end = 1.0;
  var emission_intensity_t = 0.0;
  var emission_intensity_vel = 0.05;

  // PROPERTIES

  double get emission_intensity => _emission_intensity;

  set emission_intensity(double value){
     final clamped = clamp01(value);
     if (_emission_intensity == clamped) return;
     _emission_intensity = value;
     refreshEmissionColor();
  }

  // METHODS

  void update(){
    if (type != ItemType.GameObjects_Neon_Sign_01) return;
    if (emission_intensity_vel == 0) return;
    emission_intensity_t += emission_intensity_vel;

    if (emission_intensity_t < emission_intensity_start || emission_intensity_t > emission_intensity_end){
      emission_intensity_t = clamp(emission_intensity_t, emission_intensity_start, emission_intensity_end);
      emission_intensity_vel = -emission_intensity_vel;
      // emission_intensity_t += emission_intensity_vel;
    }

    emission_intensity = interpolateDouble(
      start: emission_intensity_start,
      end: emission_intensity_end,
      t: emission_intensity_t,
    );
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
