import 'library.dart';


class GameCamera {
  static final chaseTarget = Watch(true);
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
    if (chaseTarget.value) {
      cameraFollowV3(
          target:GamePlayer.position,
          strength: GameCamera.followStrength
      );
    }
  }

  static void setModeFree(){
    chaseTarget.value = false;
  }

  static void setModeChase(){
    chaseTarget.value = true;
  }
}

