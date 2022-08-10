
import 'package:gamestream_flutter/isometric/grid.dart';

import '../grid/actions/rain_off.dart';
import '../grid/actions/rain_on.dart';

void onChangedRaining(bool raining){
  raining ? rainOn() : rainOff();
  refreshLighting();
}