import 'dart:math';

import 'package:flutter/services.dart';
import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_input.dart';
import 'package:bleed_client/game_engine/game_widget.dart';

import '../common.dart';
import 'connection.dart';
import 'functions/requestThrowGrenade.dart';
import '../keys.dart';
import '../send.dart';
import '../settings.dart';
import 'maths.dart';
import 'state.dart';
import 'utils.dart';


LogicalKeyboardKey _keyReload = LogicalKeyboardKey.keyR;

bool get keyPressedSpawnZombie => keyPressed(LogicalKeyboardKey.keyP);
bool get keyEquipHandGun => keyPressed(LogicalKeyboardKey.digit1);
bool get keyEquipShotgun => keyPressed(LogicalKeyboardKey.digit2);
bool get keyEquipSniperRifle => keyPressed(LogicalKeyboardKey.digit3);
bool get keyEquipMachineGun => keyPressed(LogicalKeyboardKey.digit4);
bool get keyAimPressed => keyPressedSpace;
bool get keySprintPressed => keyPressed(LogicalKeyboardKey.shiftLeft);
bool get keyPressedReload => keyPressed(_keyReload);

bool _throwingGrenade = false;

void readPlayerInput() {
  if (!playerAssigned) return;
  double playerScreenX = playerX - cameraX;
  double playerScreenY = playerY - cameraY;
  double halfScreenWidth = globalSize.width * 0.5;
  double halfScreenHeight = globalSize.height * 0.5;
  double xOffset = halfScreenWidth - playerScreenX;
  double yOffset = halfScreenHeight - playerScreenY;
  cameraX -= (xOffset * cameraFollow);
  cameraY -= (yOffset * cameraFollow);

  if (keyPressedSpawnZombie) {
    sendRequestSpawnNpc();
    return;
  }
  if (keyPressed(LogicalKeyboardKey.escape)){
    disconnect();
  }

  if (keyPressed(LogicalKeyboardKey.keyG)){
    if(!_throwingGrenade && mouseAvailable) {
      _throwingGrenade = true;
      double mouseDistance = distance(playerX, playerY, mouseWorldX, mouseWorldY);
      double maxRange = 400;
      double throwDistance = min(mouseDistance, maxRange);
      double strength = throwDistance / maxRange;
      requestThrowGrenade(strength);
    }
  } else if (_throwingGrenade){
    _throwingGrenade = false;
  }
  if (mouseAvailable) {
    requestAim = round(getMouseRotation(), decimals: 3);
  }

  if (keyPressedReload) {
    requestCharacterState = characterStateReloading;
    return;
  }

  if (mouseClicked || keyPressedF || keyPressedSpace) {
    requestCharacterState = characterStateFiring;
  } else {

    if (keyPressed(LogicalKeyboardKey.keyQ) && mouseAvailable){
      requestDirection = convertAngleToDirection(requestAim);
      if(keySprintPressed){
        requestCharacterState = characterStateRunning;
      }else{
        requestCharacterState = characterStateWalking;
      }
      return;
    }

    requestDirection = getKeyDirection();
    if (requestDirection == directionNone) {
      requestCharacterState = characterStateIdle;
      if (mouseAvailable) {
        double mouseWorldX = mouseX + cameraX;
        double mouseWorldY = mouseY + cameraY;
        for (dynamic npc in npcs) {
          if (distance(npc[x], npc[y], mouseWorldX, mouseWorldY) > playerAutoAimDistance) continue;
          requestCharacterState = characterStateAiming;
          requestDirection = convertAngleToDirection(requestAim);
          break;
        }
      }
    } else {
      if(keySprintPressed){
        requestCharacterState = characterStateRunning;
      }else{
        requestCharacterState = characterStateWalking;
      }
    }
  }
  if (keyEquipHandGun) sendRequestEquipHandgun();
  if (keyEquipShotgun) sendRequestEquipShotgun();
  if (keyEquipSniperRifle) sendRequestEquipSniperRifle();
  if (keyEquipMachineGun) sendRequestEquipMachineGun();
}

int getKeyDirection() {
  if (keyPressedW) {
    if (keyPressedD) {
      return directionUpRight;
    } else if (keyPressedA) {
      return directionUpLeft;
    } else {
      return directionUp;
    }
  } else if (keyPressedS) {
    if (keyPressedD) {
      return directionDownRight;
    } else if (keyPressedA) {
      return directionDownLeft;
    } else {
      return directionDown;
    }
  } else if (keyPressedA) {
    return directionLeft;
  } else if (keyPressedD) {
    return directionRight;
  }
  return directionNone;
}

void controlCamera() {
  if (keyPressedRightArrow) {
    cameraX += cameraSpeed;
  }
  if (keyPressedLeftArrow) {
    cameraX -= cameraSpeed;
  }
  if (keyPressedDownArrow) {
    cameraY += cameraSpeed;
  }
  if (keyPressedUpArrow) {
    cameraY -= cameraSpeed;
  }
}
