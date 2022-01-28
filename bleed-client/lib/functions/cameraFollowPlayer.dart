import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

void cameraFollowPlayer() {
  cameraFollow(game.player.x, game.player.y, engine.state.cameraFollowSpeed);
}

void cameraFollow(double x, double y, double speed){
  double xDiff = screenCenterWorldX - x;
  double yDiff = screenCenterWorldY - y;
  engine.state.camera.x -= xDiff * speed;
  engine.state.camera.y -= yDiff * speed;
}
