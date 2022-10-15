

import 'package:gamestream_flutter/isometric/camera_mode.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';

void onChangedMode(bool mode){
  if (mode){
    EditState.deselectGameObject();
    cameraModeSetChase();
    sendClientRequestWeatherToggleTimePassing(true);
    sendGameObjectRequestDeselect();
  } else {
    cameraModeSetFree();
    sendClientRequestWeatherToggleTimePassing(false);
  }
}