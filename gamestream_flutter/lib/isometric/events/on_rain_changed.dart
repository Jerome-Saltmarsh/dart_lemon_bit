import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_off.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';

void onRainChanged(bool raining) {
  raining ? apiGridActionRainOn() : apiGridActionRainOff();

  if (raining){
    actionScheduleLightning();
  }
}
