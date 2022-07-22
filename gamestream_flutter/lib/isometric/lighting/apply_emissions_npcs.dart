import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/npcs.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';

import 'apply_vector_emission.dart';


void applyEmissionsCharacters() {
  var maxBrightness = ambientShade.value - 1;
  if (maxBrightness < Shade.Bright) {
    maxBrightness = Shade.Bright;
  }
  if (maxBrightness > Shade.Medium) {
    maxBrightness = Shade.Medium;
  }
  for (var i = 0; i < totalCharacters; i++) {
    if (i >= characters.length) {
      return;
    }
    final character = characters[i];
    if (!character.allie) continue;
    applyVector3Emission(characters[i], maxBrightness: maxBrightness);
  }
}
