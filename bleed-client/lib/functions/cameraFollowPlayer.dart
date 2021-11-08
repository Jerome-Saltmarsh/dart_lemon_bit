import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/camera.dart';

void cameraFollowPlayer() {
  double xDiff = screenCenterWorldX - game.playerX;
  double yDiff = screenCenterWorldY - game.playerY;
  camera.x -= xDiff * settings.cameraFollow;
  camera.y -= yDiff * settings.cameraFollow;
}
