import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/isometric/classes/position.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_lang/src.dart';
import '../../isometric/enums/emission_type.dart';

class GameObject extends Position {
  final int id;
  var type = -1;
  var subType = -1;
  var health = -1;
  var maxHealth = -1;
  var emissionType = EmissionType.None;
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

  GameObject(this.id); // PROPERTIES
  
  double get healthPercentage => health.percentageOf(maxHealth);

  double get emissionIntensity => _emission_intensity;

  set emissionIntensity(double value){
    _emission_intensity = value.clamp01();
  }

  // METHODS

  void update(){
    if (emission_intensity_vel == 0) return;
    emission_intensity_t += emission_intensity_vel;

    if (emission_intensity_t < emission_intensity_start || emission_intensity_t > emission_intensity_end){
      emission_intensity_t = clamp(emission_intensity_t, emission_intensity_start, emission_intensity_end);
      emission_intensity_vel = -emission_intensity_vel;
    }

    emissionIntensity = interpolate(
      emission_intensity_start,
      emission_intensity_end,
      emission_intensity_t,
    );
  }

  @override
  String toString() => '{x: ${x.toInt()}, '
      'y: ${y.toInt()}, '
      'z: ${z.toInt()}, '
      'type: ${ItemType.getName(type)}, '
      'subType: ${ItemType.getNameSubType(type, subType)}}';
}
