import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
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
    final character = characters[i];
    if (!character.allie) continue;
    applyVector3Emission(character, maxBrightness: maxBrightness);
  }

  // for (var i = 0; i < totalGameObjects; i++) {
  //   final gameObject = gameObjects[i];
  //   if (gameObject.type == GameObjectType.Butterfly){
  //     applyVector3Emission(gameObject, maxBrightness: maxBrightness);
  //   }
  // }
}
