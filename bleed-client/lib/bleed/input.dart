import 'package:flutter/services.dart';
import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_input.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'connection.dart';
import 'keys.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

bool get keyPressedSpawnZombie => keyPressed(LogicalKeyboardKey.keyP);
bool get keyEquipHandGun => keyPressed(LogicalKeyboardKey.digit1);
bool get keyEquipShotgun => keyPressed(LogicalKeyboardKey.digit2);
bool get keyAimPressed => keyPressedSpace;

void readPlayerInput() {
  dynamic playerCharacter = getPlayerCharacter();
  if (playerCharacter == null) return;
  double playerScreenX = playerCharacter[posX] - cameraX;
  double playerScreenY = playerCharacter[posY] - cameraY;
  double halfScreenWidth = size.width * 0.5;
  double halfScreenHeight = size.height * 0.5;
  double xOffset = halfScreenWidth - playerScreenX;
  double yOffset = halfScreenHeight - playerScreenY;
  cameraX -= (xOffset * cameraFollow);
  cameraY -= (yOffset * cameraFollow);

  if (keyPressedSpawnZombie) {
    sendRequestSpawnNpc();
    return;
  }
  if (mouseAvailable) {
    requestAim = getMouseRotation();
  }

  if (mouseClicked || keyPressedF) {
    requestCharacterState = characterStateFiring;
    return;
  }else if (keyAimPressed) {
    requestCharacterState = characterStateAiming;
    requestDirection = convertAngleToDirection(requestAim);
    return;
  }

  requestDirection = getKeyDirection();
  if (requestDirection == directionNone) {
    requestCharacterState = characterStateIdle;
  } else {
    requestCharacterState = characterStateWalking;
  }
  if (keyEquipHandGun) {
    sendCommandEquipHandGun();
  }
  if (keyEquipShotgun) {
    sendCommandEquipShotgun();
  }
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
