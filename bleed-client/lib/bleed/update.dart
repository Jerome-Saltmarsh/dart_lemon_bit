import 'package:flutter_game_engine/bleed/audio.dart';
import 'package:flutter_game_engine/bleed/common.dart';
import 'package:flutter_game_engine/bleed/connection.dart';
import 'package:flutter_game_engine/bleed/keys.dart';
import 'package:flutter_game_engine/bleed/spawners/spawnBlood.dart';
import 'package:flutter_game_engine/bleed/updates/updateCharacters.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'enums/Weapons.dart';
import 'input.dart';
import 'send.dart';
import 'state.dart';
import 'updates/updateParticle.dart';
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
