import 'dart:math';

import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:lemon_math/src.dart';
import '../../../isometric/classes/position.dart';

class IsometricCamera with IsometricComponent {
  var chaseStrength = 0.001;
  var translateX = 0.0;
  var translateY = 25.0;
  var mouseFollowSensitivity = 0.03;
  var enableMouseTranslation = true;

  Position? target;

  void centerOnChaseTarget() {
    final target = this.target;
    if (target == null){
      print('isometric_camera.centerOnChaseTarget() - aborted because target is null');
      return;
    }
    print('isometric_camera.centerOnChaseTarget()');
    centerOnPosition(target);
  }

  void centerOnPosition(Position position) =>
      engine.cameraCenter(position.renderX, position.renderY);

  void update() {
    applyMouseTranslation();
  }

  void applyMouseTranslation(){
    final target = this.target;
    if (target == null) return;

    final mouseAngle = getMousePlayerAngle() + pi;
    final mouseDistance = getMousePlayerRenderDistance();
    final translateDistance = mouseDistance * mouseFollowSensitivity;
    final mouseTranslateX = adj(mouseAngle, translateDistance);
    final mouseTranslateY = opp(mouseAngle, translateDistance);
    final zoom = engine.zoom;

    var followX = 0.0;
    var followY = 0.0;

    followX +=  target.renderX;
    followY +=  target.renderY;

    if (enableMouseTranslation){
      followX += (translateX / zoom) + (mouseTranslateX * zoom);
      followY += (translateY / zoom) + (mouseTranslateY * zoom);
    }

    engine.cameraFollow(
      followX,
      followY,
      chaseStrength * zoom.clamp(0, 2.0),
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

  void centerOnPlayer() {
    target = player.position;
    centerOnChaseTarget();
  }
}

