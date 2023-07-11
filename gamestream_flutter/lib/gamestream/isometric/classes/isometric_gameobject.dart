import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/library.dart';

import '../enums/emission_type.dart';

class IsometricGameObject extends IsometricPosition {
  final int id;
  var _type = -1;
  var subType = -1;
  var health = -1;
  var maxHealth = -1;
  var active = false;
  var colorType = EmissionType.None;
  var emissionHue = 0;
  var emissionSat = 0;
  var emissionVal = 0;
  var emissionAlp = 0;
  var emissionColor = 0;
  var _emission_intensity = 1.0;
  var emission_intensity_start = 0.15;
  var emission_intensity_end = 1.0;
  var emission_intensity_t = 0.0;
  var emission_intensity_vel = 0.00;
  var highlight = false;

  IsometricGameObject(this.id); // PROPERTIES
  
  int get type => _type;

  double get healthPercentage => maxHealth <= 0 ? 0 : health / maxHealth;

  // TODO REFACTOR
  set type(int value) {
    if (_type == value) return;
    _type = value;

    if (value != GameObjectType.Object) return;

    switch (value) {
      case ObjectType.Neon_Sign_01:
        colorType = EmissionType.Color;
        emissionHue = 344;
        emissionSat = 67;
        emissionVal = 94;
        emissionAlp = 156;
        emission_intensity_vel = 0.05;
        refreshEmissionColor();
        break;
      case ObjectType.Neon_Sign_02:
        colorType = EmissionType.Color;
        emissionHue = 166;
        emissionSat = 78;
        emissionVal = 88;
        emissionAlp = 156;
        refreshEmissionColor();
        break;
      case ObjectType.Barrel_Flaming:
        colorType = EmissionType.Color;
        emission_intensity_vel = 0.1;
        emission_intensity_start = 0.78;
        emission_intensity_end = 1.0;
        break;
      case ObjectType.Grenade:
        colorType = EmissionType.Ambient;
        break;
      case ObjectType.Vending_Upgrades:
        colorType = EmissionType.Color;
        emissionHue = 209;
        emissionSat = 66;
        emissionVal = 90;
        emissionAlp = 150;
        refreshEmissionColor();
        break;
      case ObjectType.Credits:
        colorType = EmissionType.Ambient;
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
        hue: interpolate(start: gamestream.isometric.scene.ambientHue, end: emissionHue , t: emission_intensity),
        saturation: interpolate(start: gamestream.isometric.scene.ambientSaturation, end: emissionSat, t: emission_intensity),
        value: interpolate(start: gamestream.isometric.scene.ambientValue, end: emissionVal, t: emission_intensity),
        opacity: interpolate(start: gamestream.isometric.scene.ambientAlpha, end: emissionAlp, t: emission_intensity),
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

  @override
  String toString() => '{x: ${x.toInt()}, '
      'y: ${y.toInt()}, '
      'z: ${z.toInt()}, '
      'type: ${GameObjectType.getName(type)}, '
      'subType: ${GameObjectType.getNameSubType(type, subType)}}';
}
