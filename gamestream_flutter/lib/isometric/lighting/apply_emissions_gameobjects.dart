

import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/game_object_type.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';

import 'apply_vector_emission.dart';

void applyEmissionGameObjects() {
   for (var i = 0; i < totalGameObjects; i++){
      if (!GameObjectType.emitsLightBright(gameObjects[i].type)) continue;
      applyVector3Emission(gameObjects[i], maxBrightness: Shade.Very_Bright);
   }
   for (var i = 0; i < totalGameObjects; i++){
      if (gameObjects[i].type != GameObjectType.Candle) continue;
      gameObjects[i].tile.applyLight1();
      gameObjects[i].tileBelow.applyLight1();
   }
}