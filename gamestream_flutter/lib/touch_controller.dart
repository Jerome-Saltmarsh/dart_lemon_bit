
import 'dart:ui';

import 'package:gamestream_flutter/library.dart';

class TouchController {
    static var joystickCenterX = 0.0;
    static var joystickCenterY = 0.0;
    static var joystickX = 0.0;
    static var joystickY = 0.0;

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
        return GameIO.convertRadianToDirection(angle);
    }

    static void render(Canvas canvas){
        if (Engine.touches == 0) return;

            if (Engine.watchMouseLeftDown.value) {
            joystickX = Engine.mousePositionX;
            joystickY = Engine.mousePositionY;
            final radian = angleBetween(joystickX, joystickY, joystickCenterX, joystickCenterY);
            const maxDistance = 100.0;
            if (dis > maxDistance) {
                joystickCenterX = joystickX - adj(radian, maxDistance);
                joystickCenterY = joystickY - opp(radian, maxDistance);
            }
        }

        // final j = Offset(joystickX, joystickY);
        // final k = Offset(joystickCenterX, joystickCenterY);
        // canvas.drawCircle(j, 20, Engine.paint);
        // canvas.drawLine(j, k, Engine.paint);
        // canvas.drawCircle(k, 20, Engine.paint);

        canvas.drawCircle(
            Offset(
                GamePlayer.positionScreenX + adj(angle, dis),
                GamePlayer.positionScreenY + opp(angle, dis)
            ),
            10,
            Engine.paint,
        );

        // canvas.drawCircle(
        //     Offset(
        //         GamePlayer.positionScreenX,
        //         GamePlayer.positionScreenY
        //     ),
        //     20,
        //     Engine.paint,
        // );
    }

    static void update(){

    }
}