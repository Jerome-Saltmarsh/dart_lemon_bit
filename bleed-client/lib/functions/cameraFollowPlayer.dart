import 'package:bleed_client/engine/render/game_widget.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/state.dart';

void cameraFollowPlayer() {
  double xDiff = screenCenterWorldX - compiledGame.playerX;
  double yDiff = screenCenterWorldY - compiledGame.playerY;
  cameraX -= xDiff * settings.cameraFollow;
  cameraY -= yDiff * settings.cameraFollow;
}
