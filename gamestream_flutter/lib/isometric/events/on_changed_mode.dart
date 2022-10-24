

import 'package:gamestream_flutter/library.dart';

void onChangedMode(bool mode){
  if (mode){
    GameEditor.deselectGameObject();
    GameState.cameraModeSetChase();
    GameNetwork.sendClientRequestWeatherToggleTimePassing(true);
    GameNetwork.sendGameObjectRequestDeselect();
  } else {
    GameState.cameraModeSetFree();
    GameNetwork.sendClientRequestWeatherToggleTimePassing(false);
  }
}