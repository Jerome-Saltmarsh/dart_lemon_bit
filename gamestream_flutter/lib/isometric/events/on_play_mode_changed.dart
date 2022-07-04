

import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';

void onPlayModeChanged(PlayMode playMode){
   switch(playMode){
     case PlayMode.Play:
       cameraModeSetChase();
       edit.type.value = GridNodeType.Boundary;
       return;
     case PlayMode.Edit:
       cameraModeSetFree();
       return;
   }
}