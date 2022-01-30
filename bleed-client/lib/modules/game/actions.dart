
import 'package:bleed_client/functions/emit/emitPixel.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

class GameActions {

  void spawnBulletHole(double x, double y){
    game.bulletHoles[game.bulletHoleIndex].x = x;
    game.bulletHoles[game.bulletHoleIndex].y = y;
    game.bulletHoleIndex = (game.bulletHoleIndex + 1) % game.settings.maxBulletHoles;
  }

  void cameraCenterPlayer(){
    engine.actions.cameraCenter(game.player.x, game.player.y);
  }

  void emitPixelExplosion(double x, double y, {int amount = 10}) {
    for (int i = 0; i < amount; i++) {
      emitPixel(x: x, y: y);
    }
  }
}