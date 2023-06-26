import 'dart:math';

import 'package:gamestream_flutter/library.dart';

import '../classes/isometric_position.dart';

class IsometricCamera {
  final followTarget = WatchBool(true);

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

  void centerOnV3(IsometricPosition v3) => engine.cameraCenter(v3.renderX, v3.renderY);

  void update() {
    if (!followTarget.value) {
      const padding = 200.0;
      const speed = 6.0;
      if (engine.mousePositionX < padding){
         engine.cameraX -= speed;
      }
      if (engine.mousePositionX > engine.screen.width - padding){
        engine.cameraX += speed;
      }
      if (engine.mousePositionY < padding){
         engine.cameraY -= speed;
      }
      if (engine.mousePositionY > engine.screen.height - padding){
        engine.cameraY += speed;
      }

      return;
    }

    final target = this.target;
    if (target == null) return;

    final mouseAngle = getMousePlayerAngle() + pi;
    final mouseDistance = getMousePlayerRenderDistance();
    final translateDistance = mouseDistance * mouseFollowSensitivity;
    translateX = adj(mouseAngle, translateDistance);
    translateY = opp(mouseAngle, translateDistance);
    engine.cameraFollow(
        target.renderX + translateX,
        target.renderY + translateY,
        chaseStrength,
    );
  }

  void setModeFree(){
    followTarget.value = false;
  }

  void setModeChase(){
    followTarget.value = true;
  }

  void cameraSetPositionGrid(int row, int column, int z){
    cameraSetPosition(row * Node_Size, column * Node_Size, z * Node_Height);
  }

  void cameraSetPosition(double x, double y, double z){
    final renderX = (x - y) * 0.5;
    final renderY = ((y + x) * 0.5) - z;
    engine.cameraCenter(renderX, renderY);
  }

  double getMousePlayerRenderDistance(){
    final adjacent = gamestream.isometric.player.renderX - engine.mouseWorldX;
    final opposite = gamestream.isometric.player.renderY - engine.mouseWorldY;
    return hyp(adjacent, opposite);
  }

  static double getMousePlayerAngle(){
    final adjacent = gamestream.isometric.player.renderX - engine.mouseWorldX;
    final opposite = gamestream.isometric.player.renderY - engine.mouseWorldY;
    return angle(adjacent, opposite);
  }

}

