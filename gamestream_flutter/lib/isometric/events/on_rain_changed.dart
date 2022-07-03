import 'package:bleed_common/Rain.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_off.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';

void onRainChanged(Rain value) {
  value != Rain.None ? apiGridActionRainOn() : apiGridActionRainOff();
}
