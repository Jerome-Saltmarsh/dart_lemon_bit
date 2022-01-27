
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_engine/engine.dart';

void cameraCenterPlayer(){
  engine.actions.cameraCenter(game.player.x, game.player.y);
}