

import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';

void onPlayModeChanged(PlayMode playMode){
   switch(playMode){
     case PlayMode.Play:
       cameraModeSetChase();
       return;
     case PlayMode.Edit:
       cameraModeSetFree();
       return;
     case PlayMode.Debug:
       cameraModeSetChase();
       return;
     case PlayMode.Character:
       cameraModeSetChase();
       return;
   }
}