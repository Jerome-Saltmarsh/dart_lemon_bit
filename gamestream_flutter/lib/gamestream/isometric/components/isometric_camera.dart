import 'dart:math';

import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

import '../../../isometric/classes/position.dart';

class IsometricCamera {
  final Isometric isometric;
  var chaseStrength = 0.00075;
  var translateX = 0.0;
  var translateY = 0.0;
  var mouseFollowSensitivity = 0.1;

  Position? target;

  IsometricCamera(this.isometric);

  void centerOnChaseTarget() {
    if (target != null){
      centerOnV3(target!);
    }
  }

  void centerOnV3(Position v3) => isometric.engine.cameraCenter(v3.renderX, v3.renderY);

  void update() {
    final target = this.target;
    if (target == null) return;

    final mouseAngle = getMousePlayerAngle() + pi;
    final mouseDistance = getMousePlayerRenderDistance();
    final translateDistance = mouseDistance * mouseFollowSensitivity;
    translateX = adj(mouseAngle, translateDistance);
    translateY = opp(mouseAngle, translateDistance);
    isometric.engine.cameraFollow(
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
    isometric.engine.cameraCenter(renderX, renderY);
  }

  double getMousePlayerRenderDistance(){
    final adjacent = isometric.player.renderX - isometric.engine.mouseWorldX;
    final opposite = isometric.player.renderY - isometric.engine.mouseWorldY;
    return hyp2(adjacent, opposite);
  }

  double getMousePlayerAngle(){
    final adjacent = isometric.player.renderX - isometric.engine.mouseWorldX;
    final opposite = isometric.player.renderY - isometric.engine.mouseWorldY;
    return rad(adjacent, opposite);
  }

}

