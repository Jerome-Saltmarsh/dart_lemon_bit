import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/engine/state/zoom.dart';
import 'package:bleed_client/enums/Mode.dart';
import 'package:bleed_client/state/game.dart';
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
  game.playerId = -1;
  game.gameId = -1;
  game.playerUUID = "";
  game.playerX = -1;
  game.playerY = -1;
  game.totalZombies = 0;
  game.totalHumans = 0;
  game.totalBullets = 0;
  game.grenades.clear();
  game.collectables.clear();
  game.particleEmitters.clear();

  for (Vector2 bullet in game.bulletHoles) {
    bullet.x = 0;
    bullet.y = 0;
  }

  for (Particle particle in game.particles) {
    particle.active = false;
  }

  for (Vector2 bullet in game.bulletHoles) {
    bullet.x = 0;
    bullet.y = 0;
  }
  game.bulletHoleIndex = 0;
}

void clearRender() {
  tileTransforms.clear();
  tileRects.clear();
  paths.clear();
}
