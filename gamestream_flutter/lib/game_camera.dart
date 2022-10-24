import 'library.dart';

class GameCamera {
  static final cameraModeWatch = Watch(CameraMode.Chase);
  static var followStrength = 0.00075;

  static void centerOnPlayer() => centerOnV3(GamePlayer.position);
  static void centerOnV3(Vector3 v3) => Engine.cameraCenter(v3.renderX, v3.renderY);

  static void followPlayer(){
    cameraFollowV3(target: GamePlayer.position, strength: GameCamera.followStrength);
  }

  static void cameraFollowV3({required Vector3  target, double strength = 0.00075}){
    Engine.cameraFollow(target.renderX, target.renderY, strength);
  }

  static void update() {
    switch (cameraMode) {
      case CameraMode.Chase:
        GameCamera.cameraFollowV3(
            target:GamePlayer.position,
            strength: GameCamera.followStrength
        );
        break;
      case CameraMode.Locked:
        GameCamera.cameraFollowV3(target: GamePlayer.position, strength: 1.0);
        break;
      case CameraMode.Free:
        break;
    }
  }
  static CameraMode get cameraMode => cameraModeWatch.value;

  static set cameraMode(CameraMode value) {
    cameraModeWatch.value = value;
  }

  static void setModeFree(){
    cameraMode = CameraMode.Free;
  }

  static void setModeChase(){
    cameraMode = CameraMode.Chase;
  }
}

