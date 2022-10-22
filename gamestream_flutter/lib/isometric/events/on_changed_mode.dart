

import 'package:gamestream_flutter/game_library.dart';
import 'package:gamestream_flutter/isometric/camera_mode.dart';

void onChangedMode(bool mode){
  if (mode){
    GameEditor.deselectGameObject();
    cameraModeSetChase();
    GameNetwork.sendClientRequestWeatherToggleTimePassing(true);
    GameNetwork.sendGameObjectRequestDeselect();
  } else {
    cameraModeSetFree();
    GameNetwork.sendClientRequestWeatherToggleTimePassing(false);
  }
}