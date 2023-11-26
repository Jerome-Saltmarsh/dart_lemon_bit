

import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onChangedMode(Mode mode){
   switch (mode){
     case Mode.Play:
       edit.deselectGameObject();
       cameraModeSetChase();
       sendClientRequestWeatherToggleTimePassing(true);
       return;
     case Mode.Edit:
       cameraModeSetFree();
       edit.selectPlayerBlock();
       sendClientRequestWeatherToggleTimePassing(false);
       return;
   }
}