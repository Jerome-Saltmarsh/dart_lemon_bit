import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/camera.dart';

void cameraFollowPlayer() {
  cameraFollow(game.playerX, game.playerY, game.settings.cameraFollowSpeed);
}

void cameraFollow(double x, double y, double speed){
  double xDiff = screenCenterWorldX - x;
  double yDiff = screenCenterWorldY - y;
  camera.x -= xDiff * speed;
  camera.y -= yDiff * speed;
}
