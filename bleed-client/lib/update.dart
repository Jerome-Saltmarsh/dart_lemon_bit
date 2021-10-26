import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/functions/cameraFollowPlayer.dart';
import 'package:bleed_client/functions/updateParticles.dart';
import 'package:bleed_client/functions/updatePlayer.dart';
import 'package:bleed_client/getters/getDeactiveParticle.dart';

import 'connection.dart';
import 'functions/updateCharacters.dart';
import 'input.dart';
import 'state.dart';

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

