

import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/game_object_type.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';

import 'apply_vector_emission.dart';

void applyEmissionGameObjects() {
   for (var i = 0; i < Game.totalGameObjects; i++){
      if (!GameObjectType.emitsLightBright(Game.gameObjects[i].type)) continue;
      applyVector3Emission(Game.gameObjects[i], maxBrightness: Shade.Very_Bright);
   }
   for (var i = 0; i < Game.totalGameObjects; i++){
      final gameObject = Game.gameObjects[i];
      if (gameObject.type != GameObjectType.Candle) continue;
      // gameObject.tile.applyLight1();
      // gameObject.tileBelow.applyLight1();

      final nodeIndex = gridNodeIndexVector3(gameObject);
      final nodeShade = Game.nodesShade[nodeIndex];
      setNodeShade(nodeIndex, nodeShade - 1);

      if (gameObject.indexZ > 0){
         final nodeBelowIndex = gridNodeIndexVector3NodeBelow(gameObject);
         final nodeBelowShade = Game.nodesShade[nodeBelowIndex];
         setNodeShade(nodeBelowIndex, nodeBelowShade - 1);
      }
   }
}