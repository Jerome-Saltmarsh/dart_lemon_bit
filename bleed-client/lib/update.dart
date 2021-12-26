import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/cube/camera3d.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/functions/cameraFollowPlayer.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/update/updateParticles.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/state/zoom.dart';
import 'package:lemon_math/randomInt.dart';

import 'common/GameStatus.dart';
import 'functions/emit/emitMyst.dart';
import 'input.dart';
import 'network.dart';
import 'state.dart';
import 'update/updateCharacters.dart';

int emitPart = 0;
double targetZoom = 1;

void updatePlayMode() {
  if (!connected) return;
  if (game.player.uuid.value.isEmpty) return;

  switch(game.type.value){
    case GameType.None:
      break;
    case GameType.MMO:
      _updateBleed();
      break;
    case GameType.Moba:
      _updateBleed();
      break;
    case GameType.BATTLE_ROYAL:
      _updateBleed();
      break;
    case GameType.CUBE3D:
      sendRequestUpdateCube3D();
      break;
  }
}

void _updateBleed(){
  if (game.status.value == GameStatus.Finished) return;

  updateZoom();
  _updateMenuVisible();
  framesSinceEvent++;
  readPlayerInput();
  updateParticles();
  updateDeadCharacterBlood();
  if (!panningCamera && game.player.alive.value) {
    cameraFollowPlayer();
  }
  updateParticleEmitters();
  sendRequestUpdatePlayer();
}

void updateZoom() {
  double sX = screenCenterWorldX;
  double sY = screenCenterWorldY;
  double zoomDiff = targetZoom - zoom;
  zoom += zoomDiff * game.settings.zoomFollowSpeed;
  cameraCenter(sX, sY);
}

void emitAmbientMyst() {
  if (emitPart++ % 3 != 0) return;
  Particle particle = getAvailableParticle();
  if (particle == null) return;
  int row = getRandomRow();
  int column = getRandomColumn();
  particle.x = getTileWorldX(row, column);
  particle.y = getTileWorldY(row, column);
  emitMyst(particle);
}

int getRandomColumn(){
  return randomInt(0, game.totalColumns);
}

int getRandomRow(){
 return randomInt(0, game.totalRows);
}

void updateParticleEmitters() {
  for (ParticleEmitter emitter in game.particleEmitters) {
    if (emitter.next-- > 0) continue;
    emitter.next = emitter.rate;
    Particle particle = getAvailableParticle();
    particle.active = true;
    particle.x = emitter.x;
    particle.y = emitter.y;
    emitter.emit(particle);
  }
}

void _updateMenuVisible() {
  hud.state.menuVisible.value = mouseAvailable && mouseX > screen.width - 400 && mouseY < 200;
}