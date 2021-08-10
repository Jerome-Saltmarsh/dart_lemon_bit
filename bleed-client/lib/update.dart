import 'package:bleed_client/audio.dart';
import 'package:bleed_client/game_engine/game_widget.dart';

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
  framesSinceEvent++;
  controlCamera();
  readPlayerInput();

  if (connected) {

    if(gameId < 0) return;

    updateParticles();
    updateCharacters();

    if (playerId >= 0) {
      sendRequestUpdatePlayer();
      cameraCenter(playerX, playerY);

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
  }
}



