import 'dart:math';

import 'package:gamestream_flutter/library.dart';

import '../classes/isometric_position.dart';

class IsometricCamera {
  var chaseStrength = 0.00075;
  var translateX = 0.0;
  var translateY = 0.0;
  var mouseFollowSensitivity = 0.1;

  IsometricPosition? target;

  void centerOnChaseTarget() {
    if (target != null){
      centerOnV3(target!);
    }
  }

  void centerOnV3(IsometricPosition v3) => gamestream.engine.cameraCenter(v3.renderX, v3.renderY);

  void update() {
    final target = this.target;
    if (target == null) return;

    final mouseAngle = getMousePlayerAngle() + pi;
    final mouseDistance = getMousePlayerRenderDistance();
    final translateDistance = mouseDistance * mouseFollowSensitivity;
    translateX = adj(mouseAngle, translateDistance);
    translateY = opp(mouseAngle, translateDistance);
    gamestream.engine.cameraFollow(
        target.renderX + translateX,
        target.renderY + translateY,
        chaseStrength,
    );
  }

  void cameraSetPositionGrid(int row, int column, int z){
    cameraSetPosition(row * Node_Size, column * Node_Size, z * Node_Height);
  }

  void cameraSetPosition(double x, double y, double z){
    final renderX = (x - y) * 0.5;
    final renderY = ((y + x) * 0.5) - z;
    gamestream.engine.cameraCenter(renderX, renderY);
  }

  double getMousePlayerRenderDistance(){
    final adjacent = gamestream.player.renderX - gamestream.engine.mouseWorldX;
    final opposite = gamestream.player.renderY - gamestream.engine.mouseWorldY;
    return hyp2(adjacent, opposite);
  }

  static double getMousePlayerAngle(){
    final adjacent = gamestream.player.renderX - gamestream.engine.mouseWorldX;
    final opposite = gamestream.player.renderY - gamestream.engine.mouseWorldY;
    return rad(adjacent, opposite);
  }

}

