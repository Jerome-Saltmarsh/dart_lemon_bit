import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/engine/state/camera.dart';
import 'package:bleed_client/functions/cameraFollowPlayer.dart';
import 'package:bleed_client/functions/updatePlayer.dart';
import 'package:bleed_client/getters/getDeactiveParticle.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/tutorials.dart';

import 'common/Weapons.dart';
import 'connection.dart';
import 'engine/render/game_widget.dart';
import 'input.dart';
import 'instances/settings.dart';
import 'instances/sharedPreferences.dart';
import 'send.dart';
import 'state.dart';
import 'updates/updateCharacters.dart';
import 'updates/updateParticles.dart';

void updatePlayMode() {
  if (!connected) return;
  if (compiledGame.gameId < 0) return;

  framesSinceEvent++;
  readPlayerInput();
  updateParticles();
  updateDeadCharacterBlood();
  if (!panningCamera && player.alive) {
    cameraFollowPlayer();
  }

  for (ParticleEmitter emitter in compiledGame.particleEmitters) {
    if (emitter.next-- > 0) continue;
    emitter.next = emitter.rate;
    Particle particle = getDeactiveParticle();
    if (particle == null) continue;
    particle.active = true;
    particle.x = emitter.x;
    particle.y = emitter.y;
    emitter.emit(particle);
  }

  updatePlayer();
}

