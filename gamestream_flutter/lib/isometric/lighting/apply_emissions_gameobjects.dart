

import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/game_object_type.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/gameobjects.dart';
import 'package:gamestream_flutter/isometric/grid_state_util.dart';
import 'package:gamestream_flutter/isometric/nodes.dart';

import 'apply_vector_emission.dart';

void applyEmissionGameObjects() {
   for (var i = 0; i < GameState.totalGameObjects; i++){
      if (!GameObjectType.emitsLightBright(GameState.gameObjects[i].type)) continue;
      applyVector3Emission(GameState.gameObjects[i], maxBrightness: Shade.Very_Bright);
   }
   for (var i = 0; i < GameState.totalGameObjects; i++){
      final gameObject = GameState.gameObjects[i];
      if (gameObject.type != GameObjectType.Candle) continue;
      // gameObject.tile.applyLight1();
      // gameObject.tileBelow.applyLight1();

      final nodeIndex = gridNodeIndexVector3(gameObject);
      final nodeShade = GameState.nodesShade[nodeIndex];
      setNodeShade(nodeIndex, nodeShade - 1);

      if (gameObject.indexZ > 0){
         final nodeBelowIndex = gridNodeIndexVector3NodeBelow(gameObject);
         final nodeBelowShade = GameState.nodesShade[nodeBelowIndex];
         setNodeShade(nodeBelowIndex, nodeBelowShade - 1);
      }
   }
}