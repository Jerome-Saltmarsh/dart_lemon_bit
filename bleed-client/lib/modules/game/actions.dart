
import 'package:bleed_client/functions/emit/emitPixel.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

class GameActions {

  void cameraCenterPlayer(){
    engine.actions.cameraCenter(game.player.x, game.player.y);
  }

  void emitPixelExplosion(double x, double y, {int amount = 10}) {
    for (int i = 0; i < amount; i++) {
      emitPixel(x: x, y: y);
    }
  }
}