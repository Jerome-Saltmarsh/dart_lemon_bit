

import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';

void onPlayModeChanged(Mode playMode){
   switch (playMode){
     case Mode.Play:
       cameraModeSetChase();
       return;
     case Mode.Edit:
       cameraModeSetFree();
       edit.selectPlayerBlock();
       return;
   }
}