import 'package:gamestream_flutter/isometric/grid/actions/rain_off.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';

void onRainChanged(bool raining) {
  print("on rain changed $raining");
  raining ? apiGridActionRainOn() : apiGridActionRainOff();
}
