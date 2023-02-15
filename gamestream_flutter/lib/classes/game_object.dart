import 'package:gamestream_flutter/library.dart';

class GameObject extends Vector3 {
  var id = 0;
  var type = 0;
  var active = false;
  var emission = false;
  var emission_hue = 0;
  var emission_sat = 0;
  var emission_val = 0;
  var emission_alp = 0;
  var emission_col = 0;
}