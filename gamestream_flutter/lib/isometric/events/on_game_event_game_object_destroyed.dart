

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_audio.dart';

void onGameEventGameObjectDestroyed(
    double x,
    double y,
    double z,
    double angle,
    int type,
){
   switch (type){
     case GameObjectType.Barrel:
       GameAudio.crate_breaking.playXYZ(x, y, z);
       for (var i = 0; i < 5; i++) {
         GameState.spawnParticleBlockWood(x, y, z);
       }
       break;
   }
}