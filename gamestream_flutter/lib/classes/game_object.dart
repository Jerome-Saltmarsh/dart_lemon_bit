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
  var emission_intensity = 1.0;

  void refreshEmissionColor(){
    emission_col = hsvToColor4(
        hue: emission_hue,
        saturation: emission_sat,
        value: emission_val,
        opacity: emission_alp,
    );
  }
}

class EmissionType {
  static const None = 0;
  static const Ambient = 1;
  static const Color = 2;
}