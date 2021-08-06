import 'package:flutter_game_engine/bleed/audio.dart';
import 'package:flutter_game_engine/bleed/classes/Particle.dart';
import 'package:flutter_game_engine/bleed/connection.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'enums/Weapons.dart';
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

    updateParticles2();

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

void updateParticles2() {
  for(int i = 0; i < particles2.length; i++){
    if (particles2[i].duration-- <= 0){
      particles2.removeAt(i);
      i--;
      continue;
    }
    Particle particle = particles2[i];
    particle.x += particle.xv;
    particle.y += particle.yv;
    particle.z += particle.zv;
    particle.zv += particle.weight;
    particle.scale *= particle.scaleV;
  }
}
