import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

import '../enums/emission_type.dart';

class IsometricGameObject extends IsometricPosition {
  final int id;
  var _type = -1;
  var subType = -1;
  var active = false;
  var emissionType = IsometricEmissionType.None;
  var emission_hue = 0;
  var emission_sat = 0;
  var emission_val = 0;
  var emission_alp = 0;
  var emissionColor = 0;
  var _emission_intensity = 1.0;
  var emission_intensity_start = 0.15;
  var emission_intensity_end = 1.0;
  var emission_intensity_t = 0.0;
  var emission_intensity_vel = 0.00;

  IsometricGameObject(this.id); // PROPERTIES
  
  int get type => _type;
  
  set type(int value) {
    if (_type == value) return;
    _type = value;

    if (value != GameObjectType.Object) return;

    switch (value) {
      case ObjectType.Neon_Sign_01:
        emissionType = IsometricEmissionType.Color;
        emission_hue = 344;
        emission_sat = 67;
        emission_val = 94;
        emission_alp = 156;
        emission_intensity_vel = 0.05;
        refreshEmissionColor();
        break;
      case ObjectType.Neon_Sign_02:
        emissionType = IsometricEmissionType.Color;
        emission_hue = 166;
        emission_sat = 78;
        emission_val = 88;
        emission_alp = 156;
        refreshEmissionColor();
        break;
      case ObjectType.Barrel_Flaming:
        emissionType = IsometricEmissionType.Ambient;
        emission_intensity_vel = 0.1;
        emission_intensity_start = 0.78;
        emission_intensity_end = 1.0;
        break;
      case ObjectType.Grenade:
        emissionType = IsometricEmissionType.Ambient;
        break;
      case ObjectType.Vending_Upgrades:
        emissionType = IsometricEmissionType.Color;
        emission_hue = 209;
        emission_sat = 66;
        emission_val = 90;
        emission_alp = 150;
        refreshEmissionColor();
        break;
      case ObjectType.Credits:
        emissionType = IsometricEmissionType.Ambient;
        refreshEmissionColor();
        break;
    }
  }

  double get emission_intensity => _emission_intensity;

  set emission_intensity(double value){
     final clamped = clamp01(value);
     if (_emission_intensity == clamped) return;
     _emission_intensity = value;
     refreshEmissionColor();
  }

  // METHODS

  void update(){
    if (emission_intensity_vel == 0) return;
    emission_intensity_t += emission_intensity_vel;

    if (emission_intensity_t < emission_intensity_start || emission_intensity_t > emission_intensity_end){
      emission_intensity_t = clamp(emission_intensity_t, emission_intensity_start, emission_intensity_end);
      emission_intensity_vel = -emission_intensity_vel;
    }

    emission_intensity = interpolateDouble(
      start: emission_intensity_start,
      end: emission_intensity_end,
      t: emission_intensity_t,
    );
  }

  void refreshEmissionColor(){
    emissionColor = hsvToColor(
        hue: interpolate(start: gamestream.isometric.scene.ambientHue, end: emission_hue , t: emission_intensity),
        saturation: interpolate(start: gamestream.isometric.scene.ambientSaturation, end: emission_sat, t: emission_intensity),
        value: interpolate(start: gamestream.isometric.scene.ambientValue, end: emission_val, t: emission_intensity),
        opacity: interpolate(start: gamestream.isometric.scene.ambientAlpha, end: emission_alp, t: emission_intensity),
    );
  }

  bool get onscreen {
    const Pad_Distance = 75.0;
    final rx = renderX;

    if (rx < engine.Screen_Left - Pad_Distance || rx > engine.Screen_Right + Pad_Distance)
      return false;

    final ry = renderY;
    return ry > engine.Screen_Top - Pad_Distance && ry < engine.Screen_Bottom + Pad_Distance;
  }
}
