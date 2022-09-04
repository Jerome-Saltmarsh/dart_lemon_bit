

import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';

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
       break;
   }
}