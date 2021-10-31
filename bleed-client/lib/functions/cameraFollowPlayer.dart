import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/state/settings.dart';

void cameraFollowPlayer() {
  double xDiff = screenCenterWorldX - compiledGame.playerX;
  double yDiff = screenCenterWorldY - compiledGame.playerY;
  camera.x -= xDiff * settings.cameraFollow;
  camera.y -= yDiff * settings.cameraFollow;
}
