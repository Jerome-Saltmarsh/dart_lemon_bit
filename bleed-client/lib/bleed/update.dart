import 'package:flutter_game_engine/bleed/audio.dart';
import 'package:flutter_game_engine/bleed/connection.dart';

import 'enums.dart';
import 'input.dart';
import 'send.dart';
import 'state.dart';
import 'utils.dart';

void update() {
  DateTime now = DateTime.now();
  refreshDuration = now.difference(lastRefresh);
  lastRefresh = DateTime.now();
  framesSinceEvent++;
  controlCamera();
  readPlayerInput();

  if (connected) {
    if (playerAssigned) {
      sendRequestUpdatePlayer();

      if (previousWeapon != playerWeapon) {
        previousWeapon = playerWeapon;
        switch (playerWeapon) {
          case Weapon.HandGun:
            playAudioReload();
            break;
          case Weapon.Shotgun:
            playAudioCockShotgun();
        }
      }
    } else {
      sendCommandUpdate();
    }
  }
}
