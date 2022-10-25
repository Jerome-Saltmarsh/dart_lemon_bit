import 'library.dart';


class GameCamera {
  static final chaseTargetEnabled = Watch(true);
  static var chaseStrength = 0.00075;
  static var chaseTarget = GamePlayer.position;

  static void centerOnPlayer() => centerOnV3(GamePlayer.position);
  static void centerOnV3(Vector3 v3) => Engine.cameraCenter(v3.renderX, v3.renderY);

  static void update() {
    if (chaseTargetEnabled.value) {
      Engine.cameraFollow(chaseTarget.renderX, chaseTarget.renderY, chaseStrength);
    }
  }

  static void setModeFree(){
    chaseTargetEnabled.value = false;
  }

  static void setModeChase(){
    chaseTargetEnabled.value = true;
  }
}

