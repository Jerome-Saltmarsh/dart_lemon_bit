
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/engine.dart';

class GameActions {

  void cameraCenterPlayer(){
    engine.actions.cameraCenter(game.player.x, game.player.y);
  }
}