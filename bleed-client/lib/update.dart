import 'package:bleed_client/audio.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/ParticleEmitter.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/tutorials.dart';

import 'common/Weapons.dart';
import 'connection.dart';
import 'input.dart';
import 'instances/settings.dart';
import 'instances/sharedPreferences.dart';
import 'send.dart';
import 'state.dart';
import 'updates/updateCharacters.dart';
import 'updates/updateParticles.dart';
import 'utils.dart';

bool _showMenuOptions = false;

void update() {
  DateTime now = DateTime.now();
  refreshDuration = now.difference(lastRefresh);
  lastRefresh = DateTime.now();

  if (state.lobby != null) {
    sendRequestUpdateLobby();
    return;
  }

  // TODO Does not belong here
  _showHideTopLeftMenuOptions();

  if (!tutorialsFinished && tutorial.getFinished()) {
    tutorialNext();
    sharedPreferences.setInt('tutorialIndex', tutorialIndex);
  }

  if (playMode) {
    updatePlayMode();
  } else {
    updateEditMode();
  }
}

void _showHideTopLeftMenuOptions() {
  if (!mouseAvailable) return;
  if (mouseX < 300 && mouseY < 300) {
    if (!_showMenuOptions) {
      _showMenuOptions = true;
      rebuildUI();
    }
  } else {
    if (_showMenuOptions) {
      _showMenuOptions = false;
      rebuildUI();
    }
  }
}

void updatePlayMode() {
  if (!connected) return;
  if (compiledGame.gameId < 0) return;

  framesSinceEvent++;
  readPlayerInput();
  updateParticles();
  updateDeadCharacterBlood();
  if (!panningCamera && player.alive) {
    cameraTrackPlayer();
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

Particle getDeactiveParticle() {
  for (Particle particle in compiledGame.particles) {
    if (particle.active) continue;
    return particle;
  }
  return null;
}

void updatePlayer() {
  if (compiledGame.playerId < 0) return;

  sendRequestUpdatePlayer();

  // on player weapon changed
  if (previousWeapon != compiledGame.playerWeapon) {
    previousWeapon = compiledGame.playerWeapon;
    switch (compiledGame.playerWeapon) {
      case Weapon.HandGun:
        playAudioReload(screenCenterWorldX, screenCenterWorldY);
        break;
      case Weapon.Shotgun:
        playAudioCockShotgun(screenCenterWorldX, screenCenterWorldY);
        break;
      case Weapon.SniperRifle:
        playAudioSniperEquipped(screenCenterWorldX, screenCenterWorldY);
        break;
      case Weapon.AssaultRifle:
        playAudioReload(screenCenterWorldX, screenCenterWorldY);
        break;
    }
    rebuildUI();
  }
}

void cameraTrackPlayer() {
  double xDiff = screenCenterWorldX - compiledGame.playerX;
  double yDiff = screenCenterWorldY - compiledGame.playerY;
  cameraX -= xDiff * settings.cameraFollow;
  cameraY -= yDiff * settings.cameraFollow;
}
