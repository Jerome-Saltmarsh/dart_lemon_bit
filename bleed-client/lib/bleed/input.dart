import 'package:flutter/services.dart';
import 'package:flutter_game_engine/bleed/connection.dart';
import 'package:flutter_game_engine/bleed/maths.dart';
import 'package:flutter_game_engine/game_engine/engine_state.dart';
import 'package:flutter_game_engine/game_engine/game_input.dart';
import 'package:flutter_game_engine/game_engine/game_widget.dart';

import 'common.dart';
import 'keys.dart';
import 'send.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

bool get keyPressedSpawnZombie => keyPressed(LogicalKeyboardKey.keyP);

bool get keyEquipHandGun => keyPressed(LogicalKeyboardKey.digit1);

bool get keyEquipShotgun => keyPressed(LogicalKeyboardKey.digit2);

bool get keyAimPressed => keyPressedSpace;

void readPlayerInput() {
  if (player == null) return;
  double playerScreenX = player[x] - cameraX;
  double playerScreenY = player[y] - cameraY;
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
  if (keyPressed(LogicalKeyboardKey.escape)){
    disconnect();
  }

  if (mouseAvailable) {
    requestAim = getMouseRotation();
  }
  if (mouseClicked || keyPressedF || keyPressedSpace) {
    requestCharacterState = characterStateFiring;
  } else {
    requestDirection = getKeyDirection();
    if (requestDirection == directionNone) {
      requestCharacterState = characterStateIdle;
      if (mouseAvailable) {
        double mouseWorldX = mousePosX + cameraX;
        double mouseWorldY = mousePosY + cameraY;
        for (dynamic npc in npcs) {
          if (distance(npc[x], npc[y], mouseWorldX, mouseWorldY) > playerAutoAimDistance) continue;
          requestCharacterState = characterStateAiming;
          requestDirection = convertAngleToDirection(requestAim);
          break;
        }
      }
    } else {
      requestCharacterState = characterStateWalking;
    }
  }
  if (keyEquipHandGun) {
    sendRequestEquipHandgun();
  }
  if (keyEquipShotgun) {
    sendRequestEquipShotgun();
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
