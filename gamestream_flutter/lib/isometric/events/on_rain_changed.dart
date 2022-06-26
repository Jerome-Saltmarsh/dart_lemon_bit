import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_off.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';

void onRainChanged(bool raining) {
  raining ? audio.rainStart() : audio.rainStop();
  raining ? apiGridActionRainOn() : apiGridActionRainOff();
}
