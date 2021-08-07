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
    updateParticles();
    updateCharacters();

    if (playerAssigned) {
      sendRequestUpdatePlayer();

      // on player weapon changed
      if (previousWeapon != playerWeapon) {
        previousWeapon = playerWeapon;
        switch (playerWeapon) {
          case Weapon.HandGun:
            playAudioReload();
            break;
          case Weapon.Shotgun:
            playAudioCockShotgun();
            break;
          case Weapon.SniperRifle:
            playAudioSniperEquipped();
            break;
          case Weapon.MachineGun:
            playAudioReload();
            break;
        }

        redrawUI();
      }
    } else {
      sendCommandUpdate();
    }
  }
}



