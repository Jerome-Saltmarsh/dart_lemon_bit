

import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/game_object_type.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';

import 'apply_vector_emission.dart';

void applyEmissionGameObjects() {
   for (var i = 0; i < totalGameObjects; i++){
      if (!GameObjectType.emitsLightBright(gameObjects[i].type)) continue;
      applyVector3Emission(gameObjects[i], maxBrightness: Shade.Very_Bright);
   }
}