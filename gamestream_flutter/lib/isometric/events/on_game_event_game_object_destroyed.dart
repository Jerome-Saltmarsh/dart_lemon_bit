

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/particles.dart';

void onGameEventGameObjectDestroyed(
    double x,
    double y,
    double z,
    double angle,
    int type,
){
   switch (type){
     case GameObjectType.Barrel:
       audioSingleCrateBreaking.playXYZ(x, y, z);
       for (var i = 0; i < 5; i++) {
         spawnParticleShardWood(x, y, z);
       }
       break;
   }
}