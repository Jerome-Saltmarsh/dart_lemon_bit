import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/draw.dart';
import 'package:bleed_client/functions/cameraFollowPlayer.dart';
import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/send.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/update/updateParticles.dart';
import 'package:bleed_client/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_math/randomInt.dart';

import 'common/GameStatus.dart';
import 'functions/emit/emitMyst.dart';
import 'input.dart';
import 'update/updateCharacters.dart';
import 'webSocket.dart';

int emitPart = 0;
double targetZoom = 1;

void updatePlayMode() {
  if (!webSocket.connected) return;
  if (game.player.uuid.value.isEmpty) return;

  switch(game.type.value){
    case GameType.None:
      break;
    case GameType.Custom:
      _updateBleed();
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
    default:
      throw Exception("No update for ${game.type.value}");
  }
}

void _updateBleed(){
  if (game.status.value == GameStatus.Finished) return;

  game.framesSinceEvent++;
  updateZoom();
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
  double zoomDiff = targetZoom - engine.state.zoom;
  engine.state.zoom += zoomDiff * game.settings.zoomFollowSpeed;
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
  return randomInt(0, modules.isometric.state.totalColumns);
}

int getRandomRow(){
 return randomInt(0, modules.isometric.state.totalRows);
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
