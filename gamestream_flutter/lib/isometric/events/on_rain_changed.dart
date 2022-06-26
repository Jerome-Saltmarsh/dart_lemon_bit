import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/grid.dart';

void onRainChanged(bool raining) {
  raining ? audio.rainStart() : audio.rainStop();
  raining ? gridRainOn() : gridRainOff();
}
