import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/render/state/tileRects.dart';
import 'package:bleed_client/render/state/tileTransforms.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';

import '../state.dart';

void clearState() {
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
  rebuildUI();
  clearUI();
  redrawCanvas();
}

void clearCompileGameState() {
  compiledGame.playerId = -1;
  compiledGame.gameId = -1;
  compiledGame.playerUUID = "";
  compiledGame.playerX = -1;
  compiledGame.playerY = -1;
  compiledGame.totalZombies = 0;
  compiledGame.totalHumans = 0;
  compiledGame.totalBullets = 0;
  compiledGame.grenades.clear();
  compiledGame.collectables.clear();
  compiledGame.particleEmitters.clear();

  for (Vector2 bullet in compiledGame.bulletHoles) {
    bullet.x = 0;
    bullet.y = 0;
  }

  for (Particle particle in compiledGame.particles) {
    particle.active = false;
  }

  for (Vector2 bullet in compiledGame.bulletHoles) {
    bullet.x = 0;
    bullet.y = 0;
  }
  compiledGame.bulletHoleIndex = 0;
}

void clearRender() {
  tileTransforms.clear();
  tileRects.clear();
  paths.clear();
}
