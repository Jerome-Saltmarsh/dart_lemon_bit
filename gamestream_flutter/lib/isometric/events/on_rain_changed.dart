import 'package:bleed_common/Rain.dart';
import 'package:gamestream_flutter/isometric/state/src_x_.dart';

import '../watches/raining.dart';

void onRainChanged(Rain value) {
  raining.value = value != Rain.None;

  switch (value) {
    case Rain.None:
      break;
    case Rain.Light:
      srcXRainFalling = 6544.0;
      srcXRainLanding = 6691.0;
      break;
    case Rain.Heavy:
      srcXRainFalling = 6592.0;
      srcXRainLanding = 6739.0;
      break;
  }
}
