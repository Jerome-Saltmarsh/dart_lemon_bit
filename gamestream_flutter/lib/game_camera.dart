import 'library.dart';

class GameCamera {
  static void cameraCenterOnPlayer() => cameraCenterOnV3(GamePlayer.position);
  static void cameraCenterOnV3(Vector3 v3) => Engine.cameraCenter(v3.renderX, v3.renderY);
}