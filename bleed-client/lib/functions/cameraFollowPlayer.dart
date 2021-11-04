import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/settings.dart';

void cameraFollowPlayer() {
  double xDiff = screenCenterWorldX - game.playerX;
  double yDiff = screenCenterWorldY - game.playerY;
  camera.x -= xDiff * settings.cameraFollow;
  camera.y -= yDiff * settings.cameraFollow;
}
