import 'package:bleed_common/rain.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_x.dart';

import '../variables/src_x_rain_falling.dart';
import '../variables/src_x_rain_landing.dart';
import '../watches/raining.dart';

void onChangedRain(Rain value) {
  raining.value = value != Rain.None;

  switch (value) {
    case Rain.None:
      break;
    case Rain.Light:
      srcXRainFalling = AtlasSrcX.Node_Rain_Falling_Light_X;
      srcXRainLanding = AtlasSrcX.Node_Rain_Landing_Light_X;
      break;
    case Rain.Heavy:
      srcXRainFalling = AtlasSrcX.Node_Rain_Falling_Heavy_X;
      srcXRainLanding = AtlasSrcX.Node_Rain_Landing_Heavy_X;
      break;
  }
}
