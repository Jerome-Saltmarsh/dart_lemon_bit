import 'package:bleed_common/Rain.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_off.dart';
import 'package:gamestream_flutter/isometric/grid/actions/rain_on.dart';

import '../watches/raining.dart';

void onRainChanged(Rain value) {
  raining.value = value != Rain.None;
}
