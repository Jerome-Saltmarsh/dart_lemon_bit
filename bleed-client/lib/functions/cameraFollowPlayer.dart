import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';

void cameraFollowPlayer() {
  cameraFollow(game.player.x, game.player.y, game.settings.cameraFollowSpeed);
}

void cameraFollow(double x, double y, double speed){
  double xDiff = screenCenterWorldX - x;
  double yDiff = screenCenterWorldY - y;
  engine.state.camera.x -= xDiff * speed;
  engine.state.camera.y -= yDiff * speed;
}
