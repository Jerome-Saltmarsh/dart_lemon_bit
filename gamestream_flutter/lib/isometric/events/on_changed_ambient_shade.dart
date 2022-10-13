

import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';

void onChangedAmbientShade(int shade) {
  ambientColor = colorShades[shade];
  refreshLighting();
  torchesIgnited.value = shade != Shade.Very_Bright;
}


