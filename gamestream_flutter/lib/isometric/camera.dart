import 'package:lemon_engine/engine.dart';

import 'camera_mode.dart';
import 'enums/camera_mode.dart';
import 'player.dart';


void updateCameraMode() {
  switch (cameraMode){
    case CameraMode.Chase:
      engine.cameraFollow(player.renderX, player.renderY, 0.0005);
      break;
    case CameraMode.Locked:
      engine.cameraFollow(player.renderX, player.renderY, 1.0);
      break;
    case CameraMode.Free:
      break;
  }
}

void cameraCenterOnPlayer(){
  cameraSetPosition(player.renderX, player.renderY);
}

void cameraSetPosition(double x, double y){
  engine.cameraCenter(x, y);
}
