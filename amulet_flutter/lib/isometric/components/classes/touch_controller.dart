
import 'package:flutter/material.dart';
import 'package:amulet_flutter/isometric/components/isometric_component.dart';
import 'package:lemon_math/src.dart';

class TouchController with IsometricComponent {

  var joystickCenterX = 0.0;
  var joystickCenterY = 0.0;
  var joystickX = 0.0;
  var joystickY = 0.0;
  var attack = false;

  static const maxDistance = 15.0;

  double get angle => angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
  double get dis => distanceBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);

  void onClick() {
    joystickCenterX = engine.mousePositionX;
    joystickCenterY = engine.mousePositionY;
    joystickX = joystickCenterX;
    joystickY = joystickCenterY;
  }

  // int getDirection() =>
  //     engine.touches == 0 ? IsometricDirection.None : IsometricDirection.fromRadian(angle);

  void onMouseMoved(double x, double y){
    joystickX = engine.mousePositionX;
    joystickY = engine.mousePositionY;
  }

  void drawCanvas(Canvas canvas){
    // if (engine.touches == 0) return;
    //
    // if (engine.watchMouseLeftDown.value) {
    //   if (dis > maxDistance) {
    //     final radian = angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
    //     joystickCenterX = joystickX - adj(radian, maxDistance);
    //     joystickCenterY = joystickY - opp(radian, maxDistance);
    //   }
    // }
  }
}