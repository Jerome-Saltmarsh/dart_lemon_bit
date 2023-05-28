

import 'package:bleed_common/src.dart';
import 'package:gamestream_flutter/engine/instances.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game_state.dart';

void onGameEventGameObjectDestroyed(
    double x,
    double y,
    double z,
    double angle,
    int type,
){
   switch (type){
     case ItemType.GameObjects_Barrel:
       gamestream.audio.crate_breaking.playXYZ(x, y, z);
       for (var i = 0; i < 5; i++) {
         GameState.spawnParticleBlockWood(x, y, z);
       }
       break;
     case ItemType.GameObjects_Toilet:
       gamestream.audio.crate_breaking.playXYZ(x, y, z);
       for (var i = 0; i < 5; i++) {
         GameState.spawnParticleBlockWood(x, y, z);
       }
       break;
     case ItemType.GameObjects_Crate_Wooden:
       gamestream.audio.crate_breaking.playXYZ(x, y, z);
       for (var i = 0; i < 5; i++) {
         GameState.spawnParticleBlockWood(x, y, z);
       }
       break;

     case ItemType.Resource_Credit:
       for (var i = 0; i < 8; i++){
         GameState.spawnParticleConfettiByType(
           x,
           y,
           z,
           ParticleType.Confetti_Cyan,
         );
       }
   }
}