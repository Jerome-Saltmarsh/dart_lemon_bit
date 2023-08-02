
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

class TouchController {

  final Isometric isometric;

  var joystickCenterX = 0.0;
  var joystickCenterY = 0.0;
  var joystickX = 0.0;
  var joystickY = 0.0;
  var attack = false;

  static const maxDistance = 15.0;

  TouchController(this.isometric);

  double get angle => angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
  double get dis => distanceBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);

  void onClick() {
    joystickCenterX = isometric.engine.mousePositionX;
    joystickCenterY = isometric.engine.mousePositionY;
    joystickX = joystickCenterX;
    joystickY = joystickCenterY;
  }

  int getDirection() =>
      isometric.engine.touches == 0 ? IsometricDirection.None : IsometricDirection.fromRadian(angle);

  void onMouseMoved(double x, double y){
    joystickX = isometric.engine.mousePositionX;
    joystickY = isometric.engine.mousePositionY;
  }

  void render(Canvas canvas){
    if (isometric.engine.touches == 0) return;

    if (isometric.engine.watchMouseLeftDown.value) {
      if (dis > maxDistance) {
        final radian = angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
        joystickCenterX = joystickX - adj(radian, maxDistance);
        joystickCenterY = joystickY - opp(radian, maxDistance);
      }
    }
  }
}