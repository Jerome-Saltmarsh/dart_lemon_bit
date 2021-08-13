import 'package:bleed_client/audio.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/properties.dart';

import 'connection.dart';
import 'enums/Weapons.dart';
import 'input.dart';
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
  if (playerId < 0) return;

  sendRequestUpdatePlayer();

  // on player weapon changed
  if (previousWeapon != playerWeapon) {
    previousWeapon = playerWeapon;
    switch (playerWeapon) {
      case Weapon.HandGun:
        playAudioReload(centerX, centerY);
        break;
      case Weapon.Shotgun:
        playAudioCockShotgun(centerX, centerY);
        break;
      case Weapon.SniperRifle:
        playAudioSniperEquipped(centerX, centerY);
        break;
      case Weapon.MachineGun:
        playAudioReload(centerX, centerY);
        break;
    }
    redrawUI();
  }
}

void cameraTrackPlayer() {
  if (globalSize == null) return;
  double x = cameraX - playerX + (globalSize.width * 0.5 * zoom);
  double y = cameraY - playerY + (globalSize.height * 0.5 * zoom);
  cameraX -= x * 0.01;
  cameraY -= y * 0.01;
}
