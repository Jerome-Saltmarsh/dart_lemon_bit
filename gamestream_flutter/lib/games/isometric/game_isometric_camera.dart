import 'dart:math';
import '../../library.dart';


class GameIsometricCamera {
  final chaseTargetEnabled = Watch(true);
  var chaseStrength = 0.00075;
  var chaseTarget = GamePlayer.position;
  var translateX = 0.0;
  var translateY = 0.0;

  void centerOnPlayer() => centerOnV3(GamePlayer.position);
  void centerOnV3(Vector3 v3) => engine.cameraCenter(v3.renderX, v3.renderY);

  void update() {
    if (!chaseTargetEnabled.value) return;
    final mouseAngle = ClientQuery.getMousePlayerAngle() + pi;
    final mouseDistance = ClientQuery.getMousePlayerRenderDistance();
    final translateDistance = mouseDistance * ClientConstants.Mouse_Translation_Sensitivity;
    translateX = adj(mouseAngle, translateDistance);
    translateY = opp(mouseAngle, translateDistance);
    engine.cameraFollow(chaseTarget.renderX + translateX, chaseTarget.renderY + translateY, chaseStrength);
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

