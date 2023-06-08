import 'dart:math';

import 'package:gamestream_flutter/library.dart';

import 'isometric_position.dart';

class IsometricCamera {
  final chaseTargetEnabled = Watch(true);
  IsometricPosition? chaseTarget;
  var chaseStrength = 0.00075;
  var translateX = 0.0;
  var translateY = 0.0;

  IsometricCamera();

  void centerOnPlayer() {
    if (chaseTarget != null){
      centerOnV3(chaseTarget!);
    }
  }
  void centerOnV3(IsometricPosition v3) => engine.cameraCenter(v3.renderX, v3.renderY);

  void update() {
    if (!chaseTargetEnabled.value) return;
    final mouseAngle = ClientQuery.getMousePlayerAngle() + pi;
    final mouseDistance = ClientQuery.getMousePlayerRenderDistance();
    final translateDistance = mouseDistance * ClientConstants.Mouse_Translation_Sensitivity;
    translateX = adj(mouseAngle, translateDistance);
    translateY = opp(mouseAngle, translateDistance);

    if (chaseTarget != null){
      engine.cameraFollow(chaseTarget!.renderX + translateX, chaseTarget!.renderY + translateY, chaseStrength);
    }

  }

  void setModeFree(){
    chaseTargetEnabled.value = false;
  }

  void setModeChase(){
    chaseTargetEnabled.value = true;
  }

  void cameraSetPositionGrid(int row, int column, int z){
    cameraSetPosition(row * Node_Size, column * Node_Size, z * Node_Height);
  }

  void cameraSetPosition(double x, double y, double z){
    final renderX = (x - y) * 0.5;
    final renderY = ((y + x) * 0.5) - z;
    engine.cameraCenter(renderX, renderY);
  }
}

