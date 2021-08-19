import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/instances/game.dart';

import '../state.dart';

void clearState(){
  print('clearState()');
  game.playerId = -1;
  gameId = -1;
  playerUUID = "";
  npcs.clear();
  players.clear();
  bullets.clear();
  bulletHoles.clear();
  particles.clear();
  grenades.clear();
  gameEvents.clear();
  playersTransforms.clear();
  tileTransforms.clear();
  playerX = -1;
  playerY = -1;
  mode = Mode.Play;
}