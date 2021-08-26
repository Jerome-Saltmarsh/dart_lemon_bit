import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/instances/game.dart';

import '../state.dart';

void clearState(){
  print('clearState()');
  game.playerId = -1;
  game.playerUUID = "";
  game.playerX = -1;
  game.playerY = -1;
  game.npcs.clear();
  game.players.clear();
  game.bullets.clear();
  game.bulletHoles.clear();
  game.particles.clear();
  game.grenades.clear();
  zoom = 1;
  gameId = -1;
  gameEvents.clear();
  playersTransforms.clear();
  render.tileTransforms.clear();
  mode = Mode.Play;
}