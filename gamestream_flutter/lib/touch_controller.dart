
import 'dart:ui';

import 'package:gamestream_flutter/library.dart';

import 'engine/instances.dart';

class TouchController {
    static var joystickCenterX = 0.0;
    static var joystickCenterY = 0.0;
    static var joystickX = 0.0;
    static var joystickY = 0.0;
    static var attack = false;

    static const maxDistance = 15.0;

    static double get angle => angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
    static double get dis => distanceBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);

    static void onClick() {
        joystickCenterX = Engine.mousePositionX;
        joystickCenterY = Engine.mousePositionY;
        joystickX = joystickCenterX;
        joystickY = joystickCenterY;
    }

    static int getDirection(){
        if (Engine.touches == 0) return Direction.None;
        return gsEngine.io.convertRadianToDirection(angle);
    }

    static void onMouseMoved(double x, double y){
      joystickX = Engine.mousePositionX;
      joystickY = Engine.mousePositionY;
    }

    static void render(Canvas canvas){
    if (Engine.touches == 0) return;

    if (Engine.watchMouseLeftDown.value) {
      // joystickX = Engine.mousePositionX;
      // joystickY = Engine.mousePositionY;
      if (dis > maxDistance) {
        final radian = angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
        joystickCenterX = joystickX - adj(radian, maxDistance);
        joystickCenterY = joystickY - opp(radian, maxDistance);
      }
      }
    }
}