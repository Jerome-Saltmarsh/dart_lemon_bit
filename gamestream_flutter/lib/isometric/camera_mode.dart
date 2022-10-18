import 'package:gamestream_flutter/game.dart';

import 'enums/camera_mode.dart';




void cameraModeNext(){
  cameraMode = CameraMode.values[(Game.cameraMode.index + 1) % CameraMode.values.length];
}

void cameraModeSetFree(){
  cameraMode = CameraMode.Free;
}

void cameraModeSetChase(){
  cameraMode = CameraMode.Chase;
}

void set cameraMode(CameraMode value) {
  Game.cameraModeWatch.value = value;
}