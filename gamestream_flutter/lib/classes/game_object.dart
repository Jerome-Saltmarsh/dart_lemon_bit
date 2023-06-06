import 'package:gamestream_flutter/library.dart';

class GameObject extends Vector3 {
  final int id;
  var _type = -1;
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
  var emission_intensity_vel = 0.00;


  GameObject(this.id); // PROPERTIES
  
  int get type => _type;
  
  set type(int value) {
    if (_type == value) return;
    _type = value;

    switch (value) {
      case ItemType.GameObjects_Neon_Sign_01:
        emission_type = EmissionType.Color;
        emission_hue = 344;
        emission_sat = 67;
        emission_val = 94;
        emission_alp = 156;
        emission_intensity_vel = 0.05;
        refreshEmissionColor();
        break;
      case ItemType.GameObjects_Neon_Sign_02:
        emission_type = EmissionType.Color;
        emission_hue = 166;
        emission_sat = 78;
        emission_val = 88;
        emission_alp = 156;
        refreshEmissionColor();
        break;
      case ItemType.GameObjects_Barrel_Flaming:
        emission_type = EmissionType.Ambient;
        emission_intensity_vel = 0.1;
        emission_intensity_start = 0.78;
        emission_intensity_end = 1.0;
        break;
      case ItemType.Weapon_Thrown_Grenade:
        emission_type = EmissionType.Ambient;
        break;
      case ItemType.GameObjects_Vending_Upgrades:
        emission_type = EmissionType.Color;
        emission_hue = 209;
        emission_sat = 66;
        emission_val = 90;
        emission_alp = 150;
        refreshEmissionColor();
        break;
      case ItemType.Resource_Credit:
        emission_type = EmissionType.Ambient;
        // emission_type = EmissionType.Color;
        // emission_hue = 168;
        // emission_sat = 42;
        // emission_val = 97;
        // emission_alp = 200;
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
        hue: interpolate(start: gamestream.isometric.nodes.ambient_hue, end: emission_hue , t: emission_intensity),
        saturation: interpolate(start: gamestream.isometric.nodes.ambient_sat, end: emission_sat, t: emission_intensity),
        value: interpolate(start: gamestream.isometric.nodes.ambient_val, end: emission_val, t: emission_intensity),
        opacity: interpolate(start: gamestream.isometric.nodes.ambient_alp, end: emission_alp, t: emission_intensity),
    );
  }
}
