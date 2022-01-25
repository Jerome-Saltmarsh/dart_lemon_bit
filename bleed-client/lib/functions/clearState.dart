import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/modules/core/enums.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/render/state/tileRects.dart';
import 'package:bleed_client/render/state/tileTransforms.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/logic/hudLogic.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_math/Vector2.dart';


void clearState() {
  print('clearState()');
  clearCompileGameState();
  clearRender();
  engine.state.zoom = 1;
  game.gameEvents.clear();
  core.state.mode.value = Mode.Play;
  refreshUI();
  redrawCanvas();
}

void clearCompileGameState() {
  game.player.id = -1;
  game.id = -1;
  game.player.uuid.value = "";
  game.player.x = -1;
  game.player.y = -1;
  game.totalZombies.value = 0;
  game.totalHumans = 0;
  game.totalProjectiles = 0;
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
