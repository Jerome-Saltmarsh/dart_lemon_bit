import 'dart:math';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/library.dart';

import '../../../isometric/classes/position.dart';

class IsometricCamera with IsometricComponent {
  var chaseStrength = 0.00075;
  var translateX = 0.0;
  var translateY = 0.0;
  var mouseFollowSensitivity = 0.1;

  Position? target;

  void centerOnChaseTarget() {
    if (target != null){
      centerOnV3(target!);
    }
  }

  void centerOnV3(Position v3) => engine.cameraCenter(v3.renderX, v3.renderY);

  void update() {
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

  void cameraSetPositionGrid(int row, int column, int z){
    cameraSetPosition(row * Node_Size, column * Node_Size, z * Node_Height);
  }

  void setPositionIndex(int index) =>
    cameraSetPosition(
      scene.getIndexPositionX(index),
      scene.getIndexPositionY(index),
      scene.getIndexPositionZ(index),
    );

  void cameraSetPosition(double x, double y, double z){
    final renderX = (x - y) * 0.5;
    final renderY = ((y + x) * 0.5) - z;
    engine.cameraCenter(renderX, renderY);
  }

  double getMousePlayerRenderDistance(){
    final adjacent = player.renderX - engine.mouseWorldX;
    final opposite = player.renderY - engine.mouseWorldY;
    return hyp2(adjacent, opposite);
  }

  double getMousePlayerAngle(){
    final adjacent = player.renderX - engine.mouseWorldX;
    final opposite = player.renderY - engine.mouseWorldY;
    return rad(adjacent, opposite);
  }

  void clearTarget(){
    target = null;
  }

}

