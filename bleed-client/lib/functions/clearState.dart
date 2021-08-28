import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/instances/game.dart';

import '../state.dart';

void clearState(){
  print('clearState()');
  compiledGame.playerId = -1;
  compiledGame.playerUUID = "";
  compiledGame.playerX = -1;
  compiledGame.playerY = -1;
  compiledGame.npcs.clear();
  compiledGame.players.clear();
  compiledGame.bullets.clear();
  compiledGame.bulletHoles.clear();
  compiledGame.particles.clear();
  compiledGame.grenades.clear();
  zoom = 1;
  gameId = -1;
  gameEvents.clear();
  render.playersTransforms.clear();
  gameOver = false;
  render.tileTransforms.clear();
  mode = Mode.Play;
}