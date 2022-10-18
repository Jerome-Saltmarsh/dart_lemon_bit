

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game.dart';

void onGameEventGameObjectDestroyed(
    double x,
    double y,
    double z,
    double angle,
    int type,
){
   switch (type){
     case GameObjectType.Barrel:
       GameAudio.audioSingleCrateBreaking.playXYZ(x, y, z);
       for (var i = 0; i < 5; i++) {
         Game.spawnParticleBlockWood(x, y, z);
       }
       break;
   }
}