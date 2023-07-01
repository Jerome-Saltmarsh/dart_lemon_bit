import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

import '../enums/emission_type.dart';

class IsometricGameObject extends IsometricPosition {
  final int id;
  var _type = -1;
  var subType = -1;
  var active = false;
  var emission_type = IsometricEmissionType.None;
  var emission_hue = 0;
  var emission_sat = 0;
  var emission_val = 0;
  var emission_alp = 0;
  var emission_col = 0;
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
        emission_type = IsometricEmissionType.Color;
        emission_hue = 344;
        emission_sat = 67;
        emission_val = 94;
        emission_alp = 156;
        emission_intensity_vel = 0.05;
        refreshEmissionColor();
        break;
      case ObjectType.Neon_Sign_02:
        emission_type = IsometricEmissionType.Color;
        emission_hue = 166;
        emission_sat = 78;
        emission_val = 88;
        emission_alp = 156;
        refreshEmissionColor();
        break;
      case ObjectType.Barrel_Flaming:
        emission_type = IsometricEmissionType.Ambient;
        emission_intensity_vel = 0.1;
        emission_intensity_start = 0.78;
        emission_intensity_end = 1.0;
        break;
      case ObjectType.Grenade:
        emission_type = IsometricEmissionType.Ambient;
        break;
      case ObjectType.Vending_Upgrades:
        emission_type = IsometricEmissionType.Color;
        emission_hue = 209;
        emission_sat = 66;
        emission_val = 90;
        emission_alp = 150;
        refreshEmissionColor();
        break;
      case ObjectType.Credits:
        emission_type = IsometricEmissionType.Ambient;
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
    emission_col = hsvToColor(
        hue: interpolate(start: gamestream.isometric.scene.ambient_hue, end: emission_hue , t: emission_intensity),
        saturation: interpolate(start: gamestream.isometric.scene.ambient_sat, end: emission_sat, t: emission_intensity),
        value: interpolate(start: gamestream.isometric.scene.ambient_val, end: emission_val, t: emission_intensity),
        opacity: interpolate(start: gamestream.isometric.scene.ambient_alp, end: emission_alp, t: emission_intensity),
    );
  }
}
