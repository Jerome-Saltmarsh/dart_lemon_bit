import 'package:lemon_engine/engine.dart';

import 'camera_mode.dart';
import 'enums/camera_mode.dart';
import 'player.dart';

void updateCameraMode() {
  switch (cameraMode){
    case CameraMode.Chase:
      const cameraFollowSpeed = 0.001;
      final playerScreenX = player.renderX;
      final playerScreenY = player.renderY;
      engine.cameraFollow(playerScreenX, playerScreenY, cameraFollowSpeed);
      final playerScreenX2 = player.renderX;
      final playerScreenY2 = player.renderY;
      // final distanceWorldX = ((playerScreenX2 - playerScreenX) / engine.zoom) * 0.5;
      // final distanceWorldY = ((playerScreenY2 - playerScreenY) / engine.zoom) * 0.5;
      //
      // engine.camera.x += distanceWorldX * 0.5;
      // engine.camera.y += distanceWorldY * 0.5;

      // final distanceWorldX2 = ((playerScreenX2 - _previousPlayerScreenX2) / engine.zoom) * 0.5;
      // final distanceWorldY2 = ((playerScreenY2 - _previousPlayerScreenY2) / engine.zoom) * 0.5;
      //

      // engine.camera.x += distanceWorldX2 * 0.4;
      // engine.camera.y += distanceWorldY2 * 0.4;

      final distanceWorldX3 = ((playerScreenX2 - _previousPlayerScreenX3) / engine.zoom) * 0.5;
      final distanceWorldY3 = ((playerScreenY2 - _previousPlayerScreenY3) / engine.zoom) * 0.5;

      engine.camera.x += distanceWorldX3 * 0.3;
      engine.camera.y += distanceWorldY3 * 0.3;

      _previousPlayerScreenX3 = _previousPlayerScreenX2;
      _previousPlayerScreenY3 = _previousPlayerScreenY2;
      _previousPlayerScreenX2 = _previousPlayerScreenX1;
      _previousPlayerScreenY2 = _previousPlayerScreenY1;
      _previousPlayerScreenX1 = player.renderX;
      _previousPlayerScreenY2 = player.renderY;
      break;
    case CameraMode.Locked:
      engine.cameraCenter(player.x, player.y);
      break;
    case CameraMode.Free:
      break;
  }
}

void cameraCenterOnPlayer(){
  engine.cameraCenter(player.x, player.y);
  _previousPlayerScreenX1 = worldToScreenX(player.x);
  _previousPlayerScreenY1 = worldToScreenY(player.y);
  _previousPlayerScreenX2 = _previousPlayerScreenX1;
  _previousPlayerScreenY2 = _previousPlayerScreenY1;
  _previousPlayerScreenX3 = _previousPlayerScreenX1;
  _previousPlayerScreenY3 = _previousPlayerScreenY1;
}

var _previousPlayerScreenX1 = 0.0;
var _previousPlayerScreenY1 = 0.0;
var _previousPlayerScreenX2 = 0.0;
var _previousPlayerScreenY2 = 0.0;
var _previousPlayerScreenX3 = 0.0;
var _previousPlayerScreenY3 = 0.0;