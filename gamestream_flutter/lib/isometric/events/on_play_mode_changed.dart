

import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/player.dart';

void onPlayModeChanged(PlayMode playMode){
   switch (playMode){
     case PlayMode.Play:
       cameraModeSetChase();
       return;
     case PlayMode.Edit:
       cameraModeSetFree();
       edit.selectPlayerBlock();
       return;
   }
}