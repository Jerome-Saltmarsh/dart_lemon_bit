import 'package:bleed_client/audio.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/properties.dart';

import 'connection.dart';
import 'enums/Weapons.dart';
import 'input.dart';
import 'instances/game.dart';
import 'instances/settings.dart';
import 'send.dart';
import 'state.dart';
import 'updates/updateCharacters.dart';
import 'updates/updateParticles.dart';
import 'utils.dart';

void update() {
  DateTime now = DateTime.now();
  refreshDuration = now.difference(lastRefresh);
  lastRefresh = DateTime.now();

  if (playMode) {
    updatePlayMode();
  } else {
    updateEditMode();
  }
}

void updatePlayMode() {
  if (!connected) return;
  if (gameId < 0) return;

  framesSinceEvent++;
  readPlayerInput();
  updateParticles();
  updateCharacters();
  cameraTrackPlayer();
  updatePlayer();
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
      case Weapon.MachineGun:
        playAudioReload(screenCenterWorldX, screenCenterWorldY);
        break;
    }
    redrawUI();
  }
}

void cameraTrackPlayer() {
  double xDiff = screenCenterWorldX - compiledGame.playerX;
  double yDiff = screenCenterWorldY - compiledGame.playerY;
  cameraX -= xDiff * settings.cameraFollow;
  cameraY -= yDiff * settings.cameraFollow;
}
