import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/classes/Vector2.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';

import '../state.dart';
import '../ui.dart';

void clearState(){
  print('clearState()');
  clearCompileGameState();
  clearRender();
  zoom = 1;
  gameEvents.clear();
  gameOver = false;
  mode = Mode.Play;
  state.lobby = null;
  state.lobbies.clear();
  refreshUI();
  redrawUI();
  redrawGame();
}

void clearCompileGameState(){
  compiledGame.playerId = -1;
  compiledGame.gameId = -1;
  compiledGame.playerUUID = "";
  compiledGame.playerX = -1;
  compiledGame.playerY = -1;
  compiledGame.totalNpcs = 0;
  compiledGame.totalPlayers = 0;
  compiledGame.totalBullets = 0;
  compiledGame.particles.clear();
  compiledGame.grenades.clear();
  compiledGame.collectables.clear();

  for(Vector2 bullet in compiledGame.bulletHoles){
    bullet.x = 0;
    bullet.y = 0;
  }
  compiledGame.bulletHoleIndex = 0;
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