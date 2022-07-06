import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';

import 'apply_vector_emission.dart';


void applyPlayerEmissions() {
  var maxBrightness = ambientShade.value - 1;
  if (maxBrightness < Shade.Bright) {
    maxBrightness = Shade.Bright;
  }
  if (maxBrightness > Shade.Medium) {
    maxBrightness = Shade.Medium;
  }
  for (var i = 0; i < totalPlayers; i++) {
    applyVector3Emission(players[i], maxBrightness: maxBrightness);
  }
}
