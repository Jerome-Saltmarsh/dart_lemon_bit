import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/instances/game.dart';

import '../state.dart';

void clearState(){
  print('clearState()');
  clearCompileGameState();
  clearRender();
  zoom = 1;
  gameEvents.clear();
  gameOver = false;
  mode = Mode.Play;
  state.lobby = null;
  redrawUI();
}

void clearCompileGameState(){
  compiledGame.playerId = -1;
  compiledGame.gameId = -1;
  compiledGame.playerUUID = "";
  compiledGame.playerX = -1;
  compiledGame.playerY = -1;
  compiledGame.npcs.clear();
  compiledGame.players.clear();
  compiledGame.totalBullets = 0;
  compiledGame.bulletHoles.clear();
  compiledGame.particles.clear();
  compiledGame.grenades.clear();
}

void clearRender(){
  render.playersTransforms.clear();
  render.playersRects.clear();
  render.tileTransforms.clear();
  render.tileRects.clear();
  render.paths.clear();
  render.particleRects.clear();
  render.particleTransforms.clear();
  render.npcsRects.clear();
  render.npcsTransforms.clear();
}