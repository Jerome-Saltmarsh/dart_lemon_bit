import 'package:bleed_common/rain.dart';

import '../variables/src_x_rain_falling.dart';
import '../variables/src_x_rain_landing.dart';
import '../watches/raining.dart';

void onChangedRain(Rain value) {
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
