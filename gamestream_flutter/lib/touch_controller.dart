
import 'dart:ui';

import 'package:gamestream_flutter/library.dart';


class TouchController {
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

    int getDirection(){
        if (engine.touches == 0) return Direction.None;
        return gamestream.io.convertRadianToDirection(angle);
    }

    void onMouseMoved(double x, double y){
      joystickX = engine.mousePositionX;
      joystickY = engine.mousePositionY;
    }

    void render(Canvas canvas){
    if (engine.touches == 0) return;

    if (engine.watchMouseLeftDown.value) {
      if (dis > maxDistance) {
        final radian = angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
        joystickCenterX = joystickX - adj(radian, maxDistance);
        joystickCenterY = joystickY - opp(radian, maxDistance);
      }
      }
    }
}