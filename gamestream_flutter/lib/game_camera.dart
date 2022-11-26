import 'dart:math';
import 'library.dart';


class GameCamera {
  static final chaseTargetEnabled = Watch(true);
  static var chaseStrength = 0.00075;
  static var chaseTarget = GamePlayer.position;
  static var translateX = 0.0;
  static var translateY = 0.0;

  static void centerOnPlayer() => centerOnV3(GamePlayer.position);
  static void centerOnV3(Vector3 v3) => Engine.cameraCenter(v3.renderX, v3.renderY);

  static void update() {
    if (!chaseTargetEnabled.value) return;

    final mouseAngle = ClientQuery.getMousePlayerAngle() + pi;
    final mouseDistance = ClientQuery.getMousePlayerRenderDistance();
    final translateDistance = mouseDistance * ClientConstants.Mouse_Translation_Sensitivity;
    translateX = Engine.calculateAdjacent(mouseAngle, translateDistance);
    translateY = Engine.calculateOpposite(mouseAngle, translateDistance);
    Engine.cameraFollow(chaseTarget.renderX + translateX, chaseTarget.renderY + translateY, chaseStrength);
  }

  static void setModeFree(){
    chaseTargetEnabled.value = false;
  }

  static void setModeChase(){
    chaseTargetEnabled.value = true;
  }

  static void cameraSetPositionGrid(int row, int column, int z){
    cameraSetPosition(row * Node_Size, column * Node_Size, z * Node_Height);
  }

  static void cameraSetPosition(double x, double y, double z){
    final renderX = (x - y) * 0.5;
    final renderY = ((y + x) * 0.5) - z;
    Engine.cameraCenter(renderX, renderY);
  }
}

