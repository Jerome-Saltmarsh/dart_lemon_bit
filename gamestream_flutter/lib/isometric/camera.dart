import 'package:bleed_common/library.dart';
import 'package:lemon_engine/engine.dart';

import 'camera_mode.dart';
import 'enums/camera_mode.dart';
import 'player.dart';


void updateCameraMode() {
  switch (cameraMode){
    case CameraMode.Chase:
      engine.cameraFollow(player.renderX, player.renderY, 0.00075);
      break;
    case CameraMode.Locked:
      engine.cameraFollow(player.renderX, player.renderY, 1.0);
      break;
    case CameraMode.Free:
      break;
  }
}

void cameraCenterOnPlayer(){
  engine.cameraCenter(player.renderX, player.renderY);
}

void cameraSetPositionGrid(int row, int column, int z){
  cameraSetPosition(row * tileSize, column * tileSize, z * tileHeight);
}

void cameraSetPosition(double x, double y, double z){
  final renderX = (x - y) * 0.5;
  final renderY = ((y + x) * 0.5) - z;
  engine.cameraCenter(renderX, renderY);
}