import 'library.dart';

class GameCamera {
  static void centerOnPlayer() => centerOnV3(GamePlayer.position);
  static void centerOnV3(Vector3 v3) => Engine.cameraCenter(v3.renderX, v3.renderY);
}