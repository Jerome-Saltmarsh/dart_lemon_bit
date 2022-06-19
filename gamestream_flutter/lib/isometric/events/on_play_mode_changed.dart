

import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';

void onPlayModeChanged(PlayMode playMode){
   switch(playMode){
     case PlayMode.Play:
       return cameraModeSetChase();
     case PlayMode.Edit:
       return cameraModeSetFree();
   }
}